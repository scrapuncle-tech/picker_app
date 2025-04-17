import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class PdfReceiptGenerator {
  static Future<File> generateReceipt(Map<String, dynamic> receiptData) async {
    final pdf = pw.Document();

    // Load custom fonts
    final regularFont =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont =
        pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now);
    final receiptId =
        "R-${now.millisecondsSinceEpoch.toString().substring(0, 10)}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Scrap Uncle",
                          style: pw.TextStyle(fontSize: 24, font: boldFont)),
                      pw.Text("Receipt",
                          style: pw.TextStyle(fontSize: 16, font: regularFont)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Receipt #: $receiptId",
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text("Date: $formattedDate",
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text("Time: $formattedTime",
                          style: pw.TextStyle(font: regularFont)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Customer & Picker Details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("CUSTOMER:", style: pw.TextStyle(font: boldFont)),
                      pw.SizedBox(height: 5),
                      pw.Text(receiptData['customerDetails']['name'],
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text(
                          "Phone: ${receiptData['customerDetails']['phoneNo']}",
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text(
                          "Address: ${receiptData['customerDetails']['location']}",
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text("Slot: ${receiptData['customerDetails']['slot']}",
                          style: pw.TextStyle(font: regularFont)),
                    ],
                  ),
                ),
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("COLLECTED BY:",
                          style: pw.TextStyle(font: boldFont)),
                      pw.SizedBox(height: 5),
                      pw.Text(receiptData['pickerDetails']['name'],
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text("ID: ${receiptData['pickerDetails']['id']}",
                          style: pw.TextStyle(font: regularFont)),
                      pw.Text(
                          "Phone: ${receiptData['pickerDetails']['phoneNo']}",
                          style: pw.TextStyle(font: regularFont)),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Item Header
            pw.Container(
              color: PdfColors.grey300,
              padding: pw.EdgeInsets.all(10),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child:
                          pw.Text("Item", style: pw.TextStyle(font: boldFont))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text("Quantity",
                          style: pw.TextStyle(font: boldFont))),
                  pw.Expanded(
                      flex: 2,
                      child:
                          pw.Text("Rate", style: pw.TextStyle(font: boldFont))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text("Amount",
                          style: pw.TextStyle(font: boldFont),
                          textAlign: pw.TextAlign.right)),
                ],
              ),
            ),

            // Item list
            ...List.generate(receiptData['itemsCollected'].length, (index) {
              final item = receiptData['itemsCollected'][index];
              return pw.Container(
                color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(item['itemName'],
                            style: pw.TextStyle(font: regularFont))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            "${item['totalQuantity']} ${item['unit'] == 'weight' ? 'kg' : 'pcs'}",
                            style: pw.TextStyle(font: regularFont))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            "${item['price']} ${item['unit'] == 'weight' ? '/kg' : '/pc'}",
                            style: pw.TextStyle(font: regularFont))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            "₹ ${item['totalPrice'].toStringAsFixed(2)}",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: regularFont))),
                  ],
                ),
              );
            }),

            // Total
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1, color: PdfColors.black),
                  bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                ),
              ),
              padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 7,
                      child: pw.Text("Total Amount",
                          style: pw.TextStyle(font: boldFont))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                          "₹ ${receiptData['totalAmount'].toStringAsFixed(2)}",
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(font: boldFont))),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Declaration
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Declaration:", style: pw.TextStyle(font: boldFont)),
                  pw.SizedBox(height: 5),
                  pw.Text(receiptData['declaration'],
                      style: pw.TextStyle(font: regularFont)),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                        width: 150,
                        height: 40,
                        decoration: pw.BoxDecoration(
                            border:
                                pw.Border(bottom: pw.BorderSide(width: 1)))),
                    pw.Text("Customer Signature",
                        style: pw.TextStyle(font: regularFont)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                        width: 150,
                        height: 40,
                        decoration: pw.BoxDecoration(
                            border:
                                pw.Border(bottom: pw.BorderSide(width: 1)))),
                    pw.Text("Picker Signature",
                        style: pw.TextStyle(font: regularFont)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Text("Scrap Uncle", style: pw.TextStyle(font: regularFont)),
            pw.Text("Thank you for your business!",
                style: pw.TextStyle(font: regularFont)),
            pw.Text("Pickup ID: ${receiptData['pickupId'] ?? 'N/A'}",
                style: pw.TextStyle(font: regularFont)),
          ];
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file =
        File("${output.path}/receipt_${now.millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
