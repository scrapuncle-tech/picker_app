import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'print_logo_image.dart';

class BluetoothReceiptPrinter {
  List<BluetoothInfo> bondedDevices = [];
  BluetoothInfo? connectedDevice;
  bool isInitialized = false;

  Future<void> checkAndRequestPermissions() async {
    // Check and request necessary permissions
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.location, // Required on some Android versions
        ].request();

    // Debug logs for permission statuses
    statuses.forEach((perm, status) {
      debugPrint(
        "$perm permission is ${status.isGranted ? 'granted' : 'denied'}",
      );
    });

    if (statuses.values.any((status) => !status.isGranted)) {
      debugPrint("One or more permissions not granted.");
    }
  }

  // Verify Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    return await PrintBluetoothThermal.bluetoothEnabled;
  }

  // Initialize and scan for paired devices
  Future<bool> connectToPairedPrinter() async {
    // First check if Bluetooth is enabled
    final bool isBluetoothOn = await isBluetoothEnabled();
    if (!isBluetoothOn) {
      debugPrint("Bluetooth is off.");
      return false;
    }

    // Get list of paired devices
    bondedDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (bondedDevices.isEmpty) {
      debugPrint("No paired printers found.");
      return false;
    }

    // Choose the first device (or you could implement device selection)
    connectedDevice = bondedDevices.first;
    debugPrint("Attempting to connect to: ${connectedDevice!.name}");

    // Force disconnect first to reset any potentially stale connections
    await PrintBluetoothThermal.disconnect;

    // Connect to the selected device
    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: connectedDevice!.macAdress,
    );

    if (result) {
      debugPrint("Connected to printer: ${connectedDevice!.name}");
      isInitialized = true;
    } else {
      debugPrint("Failed to connect to printer.");
      connectedDevice = null;
    }
    return result;
  }

  // Ensure a connection exists or establish one
  Future<bool> ensureConnection() async {
    // Check if Bluetooth is enabled
    bool isBluetoothOn = await isBluetoothEnabled();
    if (!isBluetoothOn) {
      debugPrint("Bluetooth is off.");
      return false;
    }

    // Check current connection status
    bool isConnected = await PrintBluetoothThermal.connectionStatus;

    if (!isConnected) {
      debugPrint("No active connection. Attempting to reconnect...");

      if (connectedDevice != null) {
        // Try to reconnect using the last known device
        await PrintBluetoothThermal.disconnect; // Force disconnect first
        isConnected = await PrintBluetoothThermal.connect(
          macPrinterAddress: connectedDevice!.macAdress,
        );

        if (isConnected) {
          debugPrint("Reconnected to: ${connectedDevice!.name}");
        } else {
          debugPrint("Failed to reconnect to previously connected device.");
          // If reconnection fails, try to connect to any paired printer
          return await connectToPairedPrinter();
        }
      } else {
        // No previous connection, establish a new one
        return await connectToPairedPrinter();
      }
    } else {
      debugPrint("Printer already connected");
    }

    return isConnected;
  }

  Future<void> disconnect() async {
    debugPrint("Disconnecting from printer...");
    await PrintBluetoothThermal.disconnect;
    debugPrint("Printer disconnected");
    connectedDevice = null;
  }

  Future<bool> printReceipt(Map<String, dynamic> receiptData) async {
    bool isConnected = await ensureConnection();
    if (!isConnected) {
      debugPrint("Failed to connect to printer");
      return false;
    }

    try {
      debugPrint("Starting to print receipt...");

      // Print logo from assets
      await printLogoImage();

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(text: "SCRAP UNCLE RECEIPT\n", size: 2),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(text: "\n", size: 1),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "Customer: ${receiptData['customerDetails']['name'] ?? ''}\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "Phone: ${receiptData['customerDetails']['phoneNo'] ?? ''}\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text:
              "Address: ${receiptData['customerDetails']['location'] ?? ''}\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "Slot: ${receiptData['customerDetails']['slot'] ?? ''}\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "Date: ${receiptData['date'] ?? ''}\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "Payment Type: ${receiptData['paymentType'] ?? ''}\n\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "Picker: ${receiptData['pickerDetails']['name'] ?? ''}\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "ID: ${receiptData['pickerDetails']['id'] ?? ''}\n\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(text: "ITEMS COLLECTED\n", size: 1),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(text: "Item      Price Qty  Total\n", size: 1),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "----------------------------\n",
          size: 1,
        ),
      );

      final items = receiptData['itemsCollected'] ?? [];
      double grandTotal = 0.0;

      for (var item in items) {
        final name = item['itemName'] ?? '';
        final price = (item['price'] ?? 0.0).toStringAsFixed(2);
        final qty = item['totalQuantity'] ?? '';
        final total = item['totalPrice']?.toStringAsFixed(2) ?? '';
        grandTotal += item['totalPrice'] ?? 0.0;

        final line = _formatItemLine(name, price, qty, total);
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(text: "$line\n", size: 1),
        );
      }

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "----------------------------\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "GRAND TOTAL: ${grandTotal.toStringAsFixed(2)}\n\n",
          size: 2,
        ),
      );

      if (receiptData.containsKey('declaration')) {
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(text: "DECLARATION\n", size: 1),
        );
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
            text: "${receiptData['declaration']}\n",
            size: 1,
          ),
        );
      }

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          text: "\nThank you for your business!\n",
          size: 1,
        ),
      );

      await PrintBluetoothThermal.writeBytes([27, 100, 4]); // ESC d 4
      debugPrint("Print complete");
      return true;
    } catch (e) {
      debugPrint("Error printing receipt: $e");
      return false;
    }
  }

  // Helper method to format the line with proper spacing
  String _formatItemLine(String name, String price, dynamic qty, String total) {
    String namePad = name.padRight(8);
    if (namePad.length > 8) namePad = namePad.substring(0, 8);

    String pricePad = price.padLeft(6);
    String qtyPad = qty.toString().padLeft(4);
    String totalPad = total.padLeft(6);

    return "$namePad $pricePad $qtyPad $totalPad";
  }
}
