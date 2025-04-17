// receipt_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

import '../../components/common/custom_snackbar.component.dart';
import '../../components/update_pickup/bluetooth_device_dialog.dart';
import '../../models/pickup.entity.dart';
import 'generate_receipt.dart';
import 'pdf_receipt_generator.dart';

class ReceiptService {
  // Create receipt data from pickup information
  Map<String, dynamic> _createReceiptData(Pickup pickup) {
    return {
      'customerDetails': {
        'name': pickup.name,
        'phoneNo': pickup.mobileNo,
        'location': pickup.address,
        'slot': pickup.finalSlot.isEmpty ? pickup.slot : pickup.finalSlot,
      },
      'pickerDetails': {
        'name': 'Scrap Uncle Picker',
        'id': 'PID-001',
        'phoneNo': '123456789',
      },
      'itemsCollected':
          pickup.itemsData
              .map(
                (item) => {
                  'itemName': item.product.name,
                  'price': item.customPrice ?? item.product.price,
                  'priceType': item.customPrice != null ? 'custom' : 'actual',
                  'totalQuantity':
                      item.product.unit == 'weight'
                          ? item.weight
                          : item.quantity,
                  'unit': item.product.unit,
                  'totalPrice':
                      (item.customPrice ?? double.parse(item.product.price)) *
                      (item.product.unit == 'weight'
                          ? item.weight
                          : item.quantity),
                },
              )
              .toList(),
      'totalAmount': pickup.totalPrice,
      'date': DateTime.now().toString().split(' ')[0],
      'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
      'pickupId': pickup.id,
      'declaration': 'I confirm that the above items have been collected.',
    };
  }

  // Generate PDF receipt
  Future<void> generateAndDownloadPdf(
    BuildContext context,
    WidgetRef ref,
    Pickup pickup,
  ) async {
    // Show loading dialog
    _showLoadingDialog(context, "Generating PDF receipt...");

    try {
      // Create receipt data
      final receiptData = _createReceiptData(pickup);

      // Generate PDF using the receiptData
      final pdfFile = await PdfReceiptGenerator.generateReceipt(receiptData);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      CustomSnackBar.show(
        ref: ref,
        message: "PDF receipt saved to: ${pdfFile.path}",
        type: SnackBarType.success,
      );

      // Open the PDF file
      await OpenFile.open(pdfFile.path);
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      CustomSnackBar.show(
        ref: ref,
        message: "Failed to generate PDF: ${e.toString()}",
        type: SnackBarType.error,
      );
    }
  }

  // Handle print receipt functionality
  Future<void> handlePrintReceipt(
    BuildContext context,
    WidgetRef ref,
    Pickup pickup,
    Color secondaryColor,
    double width,
  ) async {
    // Validate items exist
    if (pickup.itemsData.isEmpty) {
      CustomSnackBar.show(
        ref: ref,
        message: "ITEMS NOT FOUND",
        type: SnackBarType.error,
      );
      return;
    }

    // Show loading dialog while initializing bluetooth
    _showLoadingDialog(
      context,
      "Searching...",
      color: secondaryColor,
      width: width,
    );

    BluetoothReceiptPrinter printerService = BluetoothReceiptPrinter();
    try {
      // Initialize bluetooth
      await printerService.getBluetooth();

      // Close the loading dialog
      Navigator.pop(context);

      // Check if devices are available
      if (printerService.availableBluetoothDevices.isEmpty) {
        CustomSnackBar.show(
          ref: ref,
          message: "No Bluetooth devices found. Creating PDF instead.",
          type: SnackBarType.error,
        );

        await generateAndDownloadPdf(context, ref, pickup);
        return;
      }

      // Show device selection dialog
      final selectedDevice =
          await BluetoothDeviceDialog.showDeviceSelectionDialog(
            context: context,
            ref: ref,
            devices: printerService.availableBluetoothDevices,
          );

      // Connect and print if device selected
      if (selectedDevice != null) {
        await _connectAndPrint(
          context,
          ref,
          selectedDevice,
          printerService,
          pickup,
          secondaryColor,
          width,
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      CustomSnackBar.show(
        ref: ref,
        message: "Bluetooth error: ${e.toString()}. Creating PDF instead.",
        type: SnackBarType.error,
      );

      await generateAndDownloadPdf(context, ref, pickup);
    }
  }

  // Connect to printer and print receipt
  Future<void> _connectAndPrint(
    BuildContext context,
    WidgetRef ref,
    dynamic selectedDevice,
    BluetoothReceiptPrinter printerService,
    Pickup pickup,
    Color secondaryColor,
    double width,
  ) async {
    // Show a connecting indicator
    _showLoadingDialog(
      context,
      "Connecting",
      color: secondaryColor,
      width: width,
    );

    try {
      // Connect to the device
      await printerService.setConnect(selectedDevice.remoteId.toString());

      // Close the loading dialog
      Navigator.pop(context);

      if (printerService.connected) {
        await _printReceiptToBluetooth(
          context,
          ref,
          printerService,
          pickup,
          secondaryColor,
          width,
        );
      } else {
        // If connection fails, create PDF instead
        CustomSnackBar.show(
          ref: ref,
          message: "Failed to connect to the printer. Creating PDF instead.",
          type: SnackBarType.error,
        );

        await generateAndDownloadPdf(context, ref, pickup);
      }
    } catch (e) {
      // Close the loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      CustomSnackBar.show(
        ref: ref,
        message: "Printing error: ${e.toString()}. Creating PDF instead.",
        type: SnackBarType.error,
      );

      await generateAndDownloadPdf(context, ref, pickup);
    } finally {
      // Disconnect when done
      await printerService.disconnect();
    }
  }

  // Print receipt to bluetooth device
  Future<void> _printReceiptToBluetooth(
    BuildContext context,
    WidgetRef ref,
    BluetoothReceiptPrinter printerService,
    Pickup pickup,
    Color secondaryColor,
    double width,
  ) async {
    // Show printing dialog
    _showLoadingDialog(
      context,
      "Printing receipt...",
      color: secondaryColor,
      width: width,
    );

    // Create receipt data for printing
    final receiptData = _createReceiptData(pickup);

    // Print the receipt
    await printerService.printTicket(receiptData);

    // Close printing dialog
    Navigator.pop(context);

    CustomSnackBar.show(
      ref: ref,
      message: "Receipt printed successfully",
      type: SnackBarType.success,
    );
  }

  // Helper method to show loading dialog
  void _showLoadingDialog(
    BuildContext context,
    String message, {
    Color? color,
    double? width,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: color),
                SizedBox(width: width != null ? width * 0.05 : 20),
                Text(message),
              ],
            ),
          ),
    );
  }

  // Method to handle completing the pickup
  void completePickup(
    BuildContext context,
    WidgetRef ref,
    Pickup currentPickupState,
    Pickup pickup,
    Function setCompleted,
  ) {
    if (currentPickupState.itemsData.isEmpty) {
      return;
    }

    setCompleted();

    CustomSnackBar.show(
      ref: ref,
      message: "Successfully completed the pickup of customer ${pickup.name}",
      type: SnackBarType.success,
    );

    Navigator.pop(context);
  }
}
