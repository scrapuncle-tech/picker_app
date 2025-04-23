// receipt_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

import '../../components/common/custom_snackbar.component.dart';
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

    // Show loading dialog while printing
    _showLoadingDialog(
      context,
      "Printing receipt...",
      color: secondaryColor,
      width: width,
    );

    BluetoothReceiptPrinter printerService = BluetoothReceiptPrinter();
    try {
      // Attempt to connect to paired printer if not already connected
      bool connected = await printerService.connectToPairedPrinter();
      if (!connected) {
        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        CustomSnackBar.log(
          status: SnackBarType.error,
          message: "No paired Bluetooth printer found.",
        );
        return;
      }
      // Print the receipt
      final receiptData = _createReceiptData(pickup);
      await printerService.printReceipt(receiptData);

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      CustomSnackBar.log(
        message: "Receipt printed successfully",
        status: SnackBarType.success,
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      CustomSnackBar.log(
        status: SnackBarType.error,
        message: "Printing error. Please check your Bluetooth printer connection.",
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
