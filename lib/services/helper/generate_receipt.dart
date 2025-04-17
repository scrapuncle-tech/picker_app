import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show Platform;

class BluetoothReceiptPrinter {
  bool connected = false;
  List<BluetoothDevice> availableBluetoothDevices = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? printCharacteristic;

  // Constructor with permission check
  BluetoothReceiptPrinter() {
    // Check permissions when created
    checkAndRequestPermissions();
  }

  // Check and request required permissions
  Future<bool> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // For Android we need location permissions for Bluetooth scanning
      // In Android 12+ we also need Bluetooth scan and connect permissions
      Map<Permission, PermissionStatus> statuses =
          await [
            Permission.location,
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
          ].request();

      bool allGranted = true;
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          allGranted = false;
          debugPrint(
            '${permission.toString()} permission is not granted: $status',
          );
        }
      });

      if (!allGranted) {
        debugPrint('Not all permissions granted, some features may not work');
        return false;
      }

      // Check if Bluetooth is on
      bool isOn =
          await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isOn) {
        debugPrint('Bluetooth is turned off');
        // On some devices, we can request to turn on Bluetooth
        try {
          await FlutterBluePlus.turnOn();
        } catch (e) {
          debugPrint('Cannot turn on Bluetooth: $e');
          return false;
        }
      }

      return true;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for Bluetooth
      // But we still check if Bluetooth is on
      bool isOn =
          await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isOn) {
        debugPrint('Bluetooth is turned off');
        return false;
      }
      return true;
    }

    return false;
  }

  // Scan for available Bluetooth devices
  Future<void> getBluetooth() async {
    // First ensure permissions are granted
    bool permissionsGranted = await checkAndRequestPermissions();
    if (!permissionsGranted) {
      debugPrint('Required permissions not granted');
      return;
    }

    try {
      // Clear previous list
      availableBluetoothDevices = [];

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      // Listen to scan results
      var subscription = FlutterBluePlus.scanResults.listen((results) {
        // Update the list of available devices
        availableBluetoothDevices = results.map((r) => r.device).toList();
        debugPrint(
          "Found ${availableBluetoothDevices.length} Bluetooth devices",
        );
      });

      // Wait for scan to complete
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
      await subscription.cancel();
    } catch (e) {
      debugPrint("Error scanning for devices: $e");
    }
  }

  // Connect to a device
  Future<void> setConnect(String deviceId) async {
    // Check permissions before connecting
    bool permissionsGranted = await checkAndRequestPermissions();
    if (!permissionsGranted) {
      debugPrint('Required permissions not granted');
      return;
    }

    try {
      // Find the device with the matching ID
      final device = availableBluetoothDevices.firstWhere(
        (d) => d.remoteId.toString() == deviceId,
        orElse: () => throw Exception("Device not found"),
      );

      selectedDevice = device;
      debugPrint("Connecting to ${device.platformName}");

      // Connect to the device
      await device.connect();

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find the first writable characteristic
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            printCharacteristic = characteristic;
            connected = true;
            debugPrint("Found writable characteristic: ${characteristic.uuid}");
            return;
          }
        }
      }

      if (printCharacteristic == null) {
        throw Exception("No writable characteristic found");
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      connected = false;
    }
  }

  // Print a receipt
  Future<void> printTicket(Map<String, dynamic> receiptData) async {
    if (!connected || printCharacteristic == null) {
      debugPrint("Not connected to a printer");
      return;
    }

    try {
      List<int> bytes = await generateReceiptData(receiptData);

      // Convert to Uint8List
      Uint8List data = Uint8List.fromList(bytes);

      // Send in chunks to accommodate BLE limitations
      const int chunkSize = 20;

      for (int i = 0; i < data.length; i += chunkSize) {
        int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
        Uint8List chunk = data.sublist(i, end);

        await printCharacteristic!.write(chunk, withoutResponse: true);
        // Small delay to prevent buffer overflow
        await Future.delayed(const Duration(milliseconds: 20));
      }

      debugPrint("Receipt printed successfully");
    } catch (e) {
      debugPrint("Error printing receipt: $e");
    }
  }

  // Disconnect from device
  Future<void> disconnect() async {
    if (selectedDevice != null) {
      await selectedDevice!.disconnect();
      connected = false;
      selectedDevice = null;
      printCharacteristic = null;
      debugPrint("Disconnected from device");
    }
  }

  // Generate the formatted receipt data
  Future<List<int>> generateReceiptData(
    Map<String, dynamic> receiptData,
  ) async {
    // Initialize the printer profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    // Add header with store info (you can customize this)
    bytes += generator.text(
      'SUPERMARKET RECEIPT',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'Thank you for shopping with us!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // CUSTOMER DETAILS
    bytes += generator.text(
      'CUSTOMER DETAILS',
      styles: const PosStyles(bold: true, underline: true),
    );

    final customerDetails = receiptData['customerDetails'] ?? {};
    bytes += generator.text('Name: ${customerDetails['name'] ?? ''}');
    bytes += generator.text('Phone: ${customerDetails['phoneNo'] ?? ''}');
    bytes += generator.text('Address: ${customerDetails['location'] ?? ''}');
    bytes += generator.text('Slot: ${customerDetails['slot'] ?? ''}');
    bytes += generator.emptyLines(1);

    // PICKER DETAILS
    bytes += generator.text(
      'PICKER DETAILS',
      styles: const PosStyles(bold: true, underline: true),
    );

    final pickerDetails = receiptData['pickerDetails'] ?? {};
    bytes += generator.text('Name: ${pickerDetails['name'] ?? ''}');
    bytes += generator.text('ID: ${pickerDetails['id'] ?? ''}');
    bytes += generator.text('Phone: ${pickerDetails['phoneNo'] ?? ''}');
    bytes += generator.emptyLines(1);

    // ITEMS COLLECTED
    bytes += generator.text(
      'ITEMS COLLECTED',
      styles: const PosStyles(bold: true, underline: true),
    );

    // Table header
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Price', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Total', width: 2, styles: const PosStyles(bold: true)),
    ]);

    bytes += generator.hr();

    // Item rows
    final itemsCollected = receiptData['itemsCollected'] ?? [];
    double grandTotal = 0.0;

    for (var item in itemsCollected) {
      final priceType = item['priceType'] ?? 'actual';
      final price = item['price'] ?? 0.0;
      final quantity = item['totalQuantity'] ?? 0;
      final unit = item['unit'] ?? '';
      final totalPrice = item['totalPrice'] ?? 0.0;

      grandTotal += totalPrice;

      bytes += generator.row([
        PosColumn(text: item['itemName'] ?? '', width: 6),
        PosColumn(text: '$price${priceType == 'custom' ? '*' : ''}', width: 2),
        PosColumn(text: '$quantity$unit', width: 2),
        PosColumn(text: totalPrice.toStringAsFixed(2), width: 2),
      ]);
    }

    bytes += generator.hr();

    // TOTAL
    bytes += generator.row([
      PosColumn(
        text: 'GRAND TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(text: '', width: 4),
      PosColumn(
        text: grandTotal.toStringAsFixed(2),
        width: 2,
        styles: const PosStyles(bold: true),
      ),
    ]);

    bytes += generator.emptyLines(1);

    // Declaration
    if (receiptData.containsKey('declaration')) {
      bytes += generator.text(
        'DECLARATION',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text(
        receiptData['declaration'] ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'Thank you for your purchase!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.cut();

    return bytes;
  }
}
