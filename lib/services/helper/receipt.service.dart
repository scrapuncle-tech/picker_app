// receipt_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../../components/common/custom_snackbar.component.dart';
import '../../models/picker.entity.dart';
import '../../models/pickup.entity.dart';
import '../../providers/auth.provider.dart';
import 'generate_receipt.dart';
import 'pdf_receipt_generator.dart';

class ReceiptService {
  // Create receipt data from pickup information
  Map<String, dynamic> _createReceiptData(Pickup pickup, Picker pickerData) {
    DateTime dateTime = DateTime.now(); // or your custom DateTime
    String formattedDate = DateFormat('MMM dd,yyyy hh:mm a').format(dateTime);

    debugPrint("ITEMS DATA: ${pickup.itemsData}");
    return {
      'customerDetails': {
        'name': pickup.name,
        'phoneNo': pickup.mobileNo,
        'location': pickup.address,
        'slot': pickup.finalSlot.isEmpty ? pickup.slot : pickup.finalSlot,
      },
      'date': formattedDate,
      'paymentType': 'UPI',
      'pickerDetails': {
        'name': pickerData.name,
        'id': pickerData.id,
        'phoneNo': pickerData.phoneNo,
      },
      'itemsCollected':
          pickup.itemsData
              .map(
                (item) => {
                  'itemName': item.product.name,
                  'price': item.customPrice ?? item.product.price,
                  'priceType': item.customPrice != null ? 'custom' : 'actual',
                  'totalQuantity':
                      item.product.unit.toString().toLowerCase() == 'weight'
                          ? item.weight
                          : item.quantity,
                  'unit': item.product.unit,
                  'totalPrice':
                      (item.customPrice ?? double.parse(item.product.price)) *
                      (item.product.unit.toString().toLowerCase() == 'weight'
                          ? item.weight
                          : item.quantity),
                },
              )
              .toList(),
      'totalAmount': pickup.totalPrice,
      'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
      'pickupId': pickup.pickupId,
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
      final pickerData = ref.read(authProvider).pickerData;

      // Create receipt data
      final receiptData = _createReceiptData(pickup, pickerData!);

      // Generate PDF using the receiptData
      final pdfGeneratorResult = await PdfReceiptGenerator.generateReceipt(
        receiptData,
      );
      final pdfFile = pdfGeneratorResult.$1;

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      CustomSnackBar.log(
        message: "PDF receipt saved to: ${pdfFile.path}",
        status: SnackBarType.success,
      );

      // Open the PDF file
      await OpenFile.open(pdfFile.path);
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      CustomSnackBar.log(
        status: SnackBarType.error,
        message: "Failed to generate PDF",
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
      CustomSnackBar.log(
        message: "ITEMS NOT FOUND",
        status: SnackBarType.error,
      );
      return;
    }

    // Create a singleton or provide a way to reuse the printer service
    // Consider making this a class variable or using a provider pattern
    BluetoothReceiptPrinter printerService = BluetoothReceiptPrinter();

    // Check permissions first
    // await printerService.checkAndRequestPermissions();

    // Check if Bluetooth is enabled
    bool isBluetoothOn = await printerService.isBluetoothEnabled();
    if (!isBluetoothOn) {
      CustomSnackBar.log(
        status: SnackBarType.error,
        message:
            "Bluetooth is turned off. Please turn on Bluetooth and try again.",
      );
      return;
    }

    // Show loading dialog while connecting and printing
    _showLoadingDialog(
      context,
      "Connecting to printer...",
      color: secondaryColor,
      width: width,
    );

    try {
      // Attempt to ensure connection to printer
      bool connected = await printerService.ensureConnection();
      if (!connected) {
        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        CustomSnackBar.log(
          status: SnackBarType.error,
          message: "No paired Bluetooth printer found or failed to connect.",
        );
        return;
      }

      // Update loading message
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showLoadingDialog(
        context,
        "Printing receipt...",
        color: secondaryColor,
        width: width,
      );

      final pickerData = ref.read(authProvider).pickerData;

      // Create receipt data
      final receiptData = _createReceiptData(pickup, pickerData!);

      // Print the receipt
      bool printSuccess = await printerService.printReceipt(receiptData);

      // Add a short delay to ensure data has been sent
      await Future.delayed(Duration(milliseconds: 500));

      // Clean disconnect after printing
      await printerService.disconnect();

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (printSuccess) {
        CustomSnackBar.log(
          message: "Receipt printed successfully",
          status: SnackBarType.success,
        );
      } else {
        CustomSnackBar.log(
          status: SnackBarType.error,
          message: "Failed to print receipt. Please try again.",
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Try to disconnect in case of error
      try {
        await printerService.disconnect();
      } catch (_) {}

      CustomSnackBar.log(
        status: SnackBarType.error,
        message:
            "Printing error: ${e.toString()}. Please check your Bluetooth printer connection.",
      );
    }
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

    CustomSnackBar.log(
      message: "Successfully completed the pickup of customer ${pickup.name}",
      status: SnackBarType.success,
    );

    Navigator.pop(context);
  }
}
