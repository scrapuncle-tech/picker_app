import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothReceiptPrinter {
  List<BluetoothInfo> bondedDevices = [];
  BluetoothInfo? connectedDevice;

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

  // Initialize and scan for paired devices
  Future<bool> connectToPairedPrinter() async {
    final bool isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isBluetoothOn) {
      debugPrint("Bluetooth is off.");
      return false;
    }

    bondedDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (bondedDevices.isEmpty) {
      debugPrint("No paired printers found.");
      return false;
    }

    connectedDevice = bondedDevices.first;
    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: connectedDevice!.macAdress,
    );
    if (result) {
      debugPrint("Connected to printer: ${connectedDevice!.name}");
    } else {
      debugPrint("Failed to connect to printer.");
    }
    return result;
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    connectedDevice = null;
  }

  Future<void> printReceipt(Map<String, dynamic> receiptData) async {
    // Check if printer is connected
    bool isConnected = await PrintBluetoothThermal.connectionStatus == true;
    if (!isConnected) {
      // Connect your printer here if needed
      debugPrint("Printer not connected");
      return;
    }

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
        text: "Address: ${receiptData['customerDetails']['location'] ?? ''}\n",
        size: 1,
      ),
    );

    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        text: "Slot: ${receiptData['customerDetails']['slot'] ?? ''}\n\n",
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
      printText: PrintTextSize(text: "Item         Qty   Total\n", size: 1),
    );

    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(text: "---------------------------\n", size: 1),
    );

    final items = receiptData['itemsCollected'] ?? [];
    double grandTotal = 0.0;
    for (var item in items) {
      final name = item['itemName'] ?? '';
      final qty = item['totalQuantity'] ?? '';
      final total = item['totalPrice']?.toStringAsFixed(2) ?? '';
      grandTotal += item['totalPrice'] ?? 0.0;
      final line = _formatLine(name, qty, total);
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(text: "$line\n", size: 1),
      );
    }

    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(text: "---------------------------\n", size: 1),
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

    // Feed and cut
    await PrintBluetoothThermal.writeBytes([27, 100, 4]); // ESC d 4

    debugPrint("Print complete");
  }

  String _formatLine(String name, dynamic qty, String total) {
    String namePad = name.padRight(12).substring(0, 12);
    String qtyPad = qty.toString().padLeft(4).substring(0, 4);
    String totalPad = total.padLeft(8).substring(0, 8);
    return "$namePad $qtyPad $totalPad";
  }
}
