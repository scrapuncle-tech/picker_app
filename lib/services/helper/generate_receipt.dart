import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart';

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

  double _parseDouble(dynamic value, [double fallback = 0.0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<bool> printReceipt(Map<String, dynamic> receiptData) async {
    bool isConnected = await ensureConnection();
    if (!isConnected) {
      debugPrint("Failed to connect to printer");
      return false;
    }
    debugPrint("receiptData['pickupId'] "+receiptData['pickupId']);

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      debugPrint("Starting to generate receipt...");

      // Logo
      final ByteData data = await rootBundle.load('assets/icons/logo_full.png');
      final Uint8List imageBytes = data.buffer.asUint8List();
      final image = decodeImage(imageBytes);
      if (image != null) {
        bytes += generator.image(image, align: PosAlign.center);
      }

      // Header
      bytes += generator.text(
        'SCRAP UNCLE PICKUP RECEIPT',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      bytes += generator.text('-------------------------------');

      bytes += generator.feed(1);

      // Date & Payment Type
      bytes += generator.text(
        'Pickup ID: ${receiptData['pickupId'] ?? ''}',
      );
      bytes += generator.text('Date: ${receiptData['date'] ?? ''}');
      bytes += generator.text(
        'Payment Type: ${receiptData['paymentType'] ?? ''}',
      );

      // Picker Info
      bytes += generator.text(
        'Picker: ${receiptData['pickerDetails']['name'] ?? ''}',
      );
      // bytes += generator.text(
      //   'Phone no: ${receiptData['pickerDetails']['phoneNo'] ?? ''}',
      // );

      bytes += generator.feed(1);

      // Items Header
      bytes += generator.text(
        'ITEMS COLLECTED',
        styles: PosStyles(bold: true, underline: true),
      );
      bytes += generator.text('-------------------------------');
      bytes += generator.row([
        PosColumn(
          text: 'Price',
          width: 4,
          styles: PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Qty',
          width: 4,
          styles: PosStyles(align: PosAlign.center, bold: true),
        ),
        PosColumn(
          text: 'Total',
          width: 4,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.text('-------------------------------');

      // Items List
      final items = receiptData['itemsCollected'] ?? [];
      double grandTotal = 0.0;

      for (var item in items) {
        try {
          final index = (items.indexOf(item) + 1).toString();
          final name = '$index. ${item['itemName']?.toString() ?? 'Unknown'}';
          final priceVal = _parseDouble(item['price']);
          final qtyVal = _parseDouble(item['totalQuantity']);
          final totalVal = _parseDouble(item['totalPrice']);

          grandTotal += totalVal;

          // First row: item name (can wrap to multiple lines if needed)
          bytes += generator.row([
            PosColumn(
              text: name,
              width: 12,
              styles: PosStyles(align: PosAlign.left),
            ),
          ]);

          // Second row: price | qty | total, aligned
          bytes += generator.row([
            PosColumn(
              text: 'Rs.${priceVal.toStringAsFixed(2)}',
              width: 4,
              styles: PosStyles(align: PosAlign.left),
            ),
            PosColumn(
              text: qtyVal.toString(),
              width: 4,
              styles: PosStyles(align: PosAlign.center),
            ),
            PosColumn(
              text: 'Rs.${totalVal.toStringAsFixed(2)}',
              width: 4,
              styles: PosStyles(align: PosAlign.right),
            ),
          ]);
        } catch (e) {
          debugPrint("Error processing item: $e");
        }
      }

      bytes += generator.text('-------------------------------');
      bytes += generator.row([
        PosColumn(
          text: 'Grand total',
          width: 6,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Rs.${grandTotal.toStringAsFixed(2)}',
          width: 6,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.text('-------------------------------');

      bytes += generator.feed(1);
      bytes += generator.text('Signature: __________________');
      bytes += generator.feed(2);
      bytes += generator.text(
        'Thank you for your business!',
        styles: PosStyles(align: PosAlign.center),
      );

      bytes += generator.feed(4);
      bytes += generator.cut();

      // Send bytes to printer
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint("Print result: $result");
      return result == true;
    } catch (e) {
      debugPrint("Error printing receipt: $e");
      return false;
    }
  }

  // Future<bool> printReceipt(Map<String, dynamic> receiptData) async {
  //   bool isConnected = await ensureConnection();
  //   if (!isConnected) {
  //     debugPrint("Failed to connect to printer");
  //     return false;
  //   }

  //   try {
  //     debugPrint("Starting to print receipt...");

  //     // Print logo from assets
  //     await printLogoImage();

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(text: "SCRAP UNCLE RECEIPT\n", size: 2),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(text: "\n", size: 1),
  //     );

  //     // await PrintBluetoothThermal.writeString(
  //     //   printText: PrintTextSize(
  //     //     text: "Customer: ${receiptData['customerDetails']['name'] ?? ''}\n",
  //     //     size: 1,
  //     //   ),
  //     // );

  //     // await PrintBluetoothThermal.writeString(
  //     //   printText: PrintTextSize(
  //     //     text: "Phone: ${receiptData['customerDetails']['phoneNo'] ?? ''}\n",
  //     //     size: 1,
  //     //   ),
  //     // );

  //     // await PrintBluetoothThermal.writeString(
  //     //   printText: PrintTextSize(
  //     //     text:
  //     //         "Address: ${receiptData['customerDetails']['location'] ?? ''}\n",
  //     //     size: 1,
  //     //   ),
  //     // );

  //     // await PrintBluetoothThermal.writeString(
  //     //   printText: PrintTextSize(
  //     //     text: "Slot: ${receiptData['customerDetails']['slot'] ?? ''}\n",
  //     //     size: 1,
  //     //   ),
  //     // );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "Date: ${receiptData['date'] ?? ''}\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "Payment Type: ${receiptData['paymentType'] ?? ''}\n\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "Picker: ${receiptData['pickerDetails']['name'] ?? ''}\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "ID: ${receiptData['pickerDetails']['id'] ?? ''}\n\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(text: "ITEMS COLLECTED\n", size: 1),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(text: "Item      Price Qty  Total\n", size: 1),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "----------------------------\n",
  //         size: 1,
  //       ),
  //     );

  //     final items = receiptData['itemsCollected'] ?? [];
  //     double grandTotal = 0.0;

  //     for (var item in items) {
  //       try {
  //         final name = item['itemName']?.toString() ?? 'Unknown';
  //         final priceVal = item['price'] ?? 0.0;
  //         final qtyVal = item['totalQuantity'] ?? 0;
  //         final totalVal = item['totalPrice'] ?? (priceVal * qtyVal);

  //         final price =
  //             (priceVal is num) ? priceVal.toStringAsFixed(2) : "0.00";
  //         final qty = qtyVal.toString();
  //         final total =
  //             (totalVal is num) ? totalVal.toStringAsFixed(2) : "0.00";

  //         grandTotal += (totalVal is num) ? totalVal : 0.0;

  //         final line = _formatItemLine(name, price, qty, total);
  //         await PrintBluetoothThermal.writeString(
  //           printText: PrintTextSize(text: "$line\n", size: 1),
  //         );
  //       } catch (e) {
  //         debugPrint("Error processing item: $e");
  //       }
  //     }

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "----------------------------\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "GRAND TOTAL: ${grandTotal.toStringAsFixed(2)}\n\n",
  //         size: 2,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "Signature: ----------------------------\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeString(
  //       printText: PrintTextSize(
  //         text: "\nThank you for your business!\n",
  //         size: 1,
  //       ),
  //     );

  //     await PrintBluetoothThermal.writeBytes([27, 100, 4]); // ESC d 4
  //     debugPrint("Print complete");
  //     return true;
  //   } catch (e) {
  //     debugPrint("Error printing receipt: $e");
  //     return false;
  //   }
  // }

  // // Helper method to format the line with proper spacing
  // String _formatItemLine(String name, String price, dynamic qty, String total) {
  //   String namePad = name.padRight(8);
  //   if (namePad.length > 8) namePad = namePad.substring(0, 8);

  //   String pricePad = price.padLeft(6);
  //   String qtyPad = qty.toString().padLeft(4);
  //   String totalPad = total.padLeft(6);

  //   return "$namePad $pricePad $qtyPad $totalPad";
  // }
}
