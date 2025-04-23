import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:async';

class BluetoothReceiptPrinter {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  BluetoothDevice? connectedDevice;

  // Connect to the first paired printer (or you can filter by name/address)
  Future<bool> connectToPairedPrinter() async {
    try {
      List<BluetoothDevice> devices = await printer.getBondedDevices();
      if (devices.isEmpty) {
        debugPrint("No paired Bluetooth printers found.");
        return false;
      }
      // Optionally, select the device by name or address
      BluetoothDevice device = devices.first;
      await printer.connect(device);
      connectedDevice = device;
      debugPrint("Connected to printer: ${device.name}");
      return true;
    } catch (e) {
      debugPrint("Failed to connect to printer: $e");
      return false;
    }
  }

  Future<void> disconnect() async {
    await printer.disconnect();
    connectedDevice = null;
  }

  // Print a formatted receipt to the connected printer
  Future<void> printReceipt(Map<String, dynamic> receiptData) async {
    if (connectedDevice == null) {
      bool connected = await connectToPairedPrinter();
      if (!connected) {
        debugPrint("No printer connected.");
        return;
      }
    }
    // Example: format the receipt for 58mm printer
    printer.printNewLine();
    printer.printCustom("SCRAP UNCLE RECEIPT", 2, 1); // Large, Centered
    printer.printNewLine();
    printer.printCustom(
      "Customer: ${receiptData['customerDetails']['name'] ?? ''}",
      1,
      0,
    );
    printer.printCustom(
      "Phone: ${receiptData['customerDetails']['phoneNo'] ?? ''}",
      1,
      0,
    );
    printer.printCustom(
      "Address: ${receiptData['customerDetails']['location'] ?? ''}",
      1,
      0,
    );
    printer.printCustom(
      "Slot: ${receiptData['customerDetails']['slot'] ?? ''}",
      1,
      0,
    );
    printer.printNewLine();
    printer.printCustom(
      "Picker: ${receiptData['pickerDetails']['name'] ?? ''}",
      1,
      0,
    );
    printer.printCustom(
      "ID: ${receiptData['pickerDetails']['id'] ?? ''}",
      1,
      0,
    );
    printer.printNewLine();
    printer.printCustom("ITEMS COLLECTED", 1, 1);
    printer.printCustom("Item         Qty   Total", 1, 0);
    printer.printCustom("---------------------------", 1, 0);
    final items = receiptData['itemsCollected'] ?? [];
    double grandTotal = 0.0;
    for (var item in items) {
      final name = item['itemName'] ?? '';
      final qty = item['totalQuantity'] ?? '';
      final total = item['totalPrice']?.toStringAsFixed(2) ?? '';
      grandTotal += item['totalPrice'] ?? 0.0;
      // Make sure the line fits 58mm width
      final line = _formatLine(name, qty, total);
      printer.printCustom(line, 1, 0);
    }
    printer.printCustom("---------------------------", 1, 0);
    printer.printCustom("GRAND TOTAL: ${grandTotal.toStringAsFixed(2)}", 2, 0);
    printer.printNewLine();
    if (receiptData.containsKey('declaration')) {
      printer.printCustom("DECLARATION", 1, 1);
      printer.printCustom(receiptData['declaration'] ?? '', 1, 0);
    }
    printer.printNewLine();
    printer.printCustom("Thank you for your business!", 1, 1);
    printer.printNewLine();
    printer.paperCut();
  }

  // Helper to format a line for 58mm width (adjust as needed)
  String _formatLine(String name, dynamic qty, String total) {
    // Pad/truncate to fit 32 chars (approx 58mm)
    String namePad = name.padRight(12).substring(0, 12);
    String qtyPad = qty.toString().padLeft(4).substring(0, 4);
    String totalPad = total.padLeft(8).substring(0, 8);
    return "$namePad $qtyPad $totalPad";
  }
}
