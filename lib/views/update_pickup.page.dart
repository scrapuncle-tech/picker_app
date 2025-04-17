import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

import '../components/common/custom_back_button.component.dart';
import '../components/common/custom_inkwell.component.dart';
import '../components/common/custom_snackbar.component.dart';
import '../components/common/gradient_button.component.dart';
import '../components/common/text.component.dart';
import '../components/common/phone_call_button.component.dart';
import '../components/common/watsapp_button.component.dart';
import '../components/update_pickup/bluetooth_device_dialog.dart';
import '../components/update_pickup/item_display_card.componenet.dart';
import '../components/update_pickup/location_map_button.component.dart';
import '../components/update_pickup/pickupinfo_tile.component.dart';
import '../models/item.entity.dart';
import '../models/pickup.entity.dart';
import '../providers/current_pickup.provider.dart';
import '../services/helper/generate_receipt.dart';
import '../services/helper/pdf_receipt_generator.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';
import 'add_item.page.dart';

class UpdatePickupPage extends ConsumerWidget {
  const UpdatePickupPage({super.key});

  // Generate PDF receipt
  Future<void> _generateAndDownloadPdf(
    BuildContext context,
    WidgetRef ref,
    Pickup pickup,
    Pickup currentPickupState,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                CustomText(text: "Generating PDF receipt..."),
              ],
            ),
          ),
    );

    try {
      // Create the receipt data for PDF
      final receiptData = {
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
            currentPickupState.itemsData
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
        'totalAmount': currentPickupState.totalPrice,
        'date': DateTime.now().toString().split(' ')[0],
        'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
        'pickupId': pickup.id,
        'declaration': 'I confirm that the above items have been collected.',
      };

      // Generate PDF using the receiptData
      final pdfFile = await PdfReceiptGenerator.generateReceipt(receiptData);

      // Close loading dialog
      Navigator.pop(context);

      // Open the PDF file or show download success message
      CustomSnackBar.show(
        ref: ref,
        message: "PDF receipt saved to: ${pdfFile.path}",
        type: SnackBarType.success,
      );

      // You might want to open the PDF with a viewer
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
  Future<void> _handlePrintReceipt(
    BuildContext context,
    WidgetRef ref,
    Pickup pickup,
    Pickup currentPickupState,
    CustomColorData colorData,
    double width,
  ) async {
    if (currentPickupState.itemsData.isEmpty) {
      CustomSnackBar.show(
        ref: ref,
        message: "ITEMS NOT FOUND",
        type: SnackBarType.error,
      );
      return;
    }

    // Show loading dialog while initializing bluetooth
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: colorData.secondaryColor(1)),
                SizedBox(width: width * 0.05),
                CustomText(text: "Searching..."),
              ],
            ),
          ),
    );

    BluetoothReceiptPrinter printerService = BluetoothReceiptPrinter();
    try {
      await printerService.getBluetooth();

      // Close the loading dialog
      Navigator.pop(context);

      if (printerService.availableBluetoothDevices.isEmpty) {
        CustomSnackBar.show(
          ref: ref,
          message: "No Bluetooth devices found. Creating PDF instead.",
          type: SnackBarType.error,
        );

        await _generateAndDownloadPdf(context, ref, pickup, currentPickupState);
        return;
      }

      final selectedDevice =
          await BluetoothDeviceDialog.showDeviceSelectionDialog(
            context: context,
            ref: ref,
            devices: printerService.availableBluetoothDevices,
          );

      if (selectedDevice != null) {
        await _connectAndPrint(
          context,
          ref,
          selectedDevice,
          printerService,
          pickup,
          currentPickupState,
          colorData,
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

      await _generateAndDownloadPdf(context, ref, pickup, currentPickupState);
    }
  }

  // Connect to printer and print receipt
  Future<void> _connectAndPrint(
    BuildContext context,
    WidgetRef ref,
    dynamic selectedDevice,
    BluetoothReceiptPrinter printerService,
    Pickup pickup,
    Pickup currentPickupState,
    CustomColorData colorData,
    double width,
  ) async {
    // Show a connecting indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: colorData.secondaryColor(1)),
                SizedBox(width: width * 0.05),
                CustomText(text: "Connecting"),
              ],
            ),
          ),
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
          currentPickupState,
          colorData,
          width,
        );
      } else {
        // If connection fails, create PDF instead
        CustomSnackBar.show(
          ref: ref,
          message: "Failed to connect to the printer. Creating PDF instead.",
          type: SnackBarType.error,
        );

        await _generateAndDownloadPdf(context, ref, pickup, currentPickupState);
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

      await _generateAndDownloadPdf(context, ref, pickup, currentPickupState);
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
    Pickup currentPickupState,
    CustomColorData colorData,
    double width,
  ) async {
    // Show printing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: colorData.secondaryColor(1)),
                SizedBox(width: width * 0.05),
                CustomText(text: "Printing receipt..."),
              ],
            ),
          ),
    );

    // Create receipt data
    final receiptData = {
      'customerDetails': {
        'name': pickup.name,
        'phoneNo': pickup.mobileNo,
        'location': pickup.address,
        'slot': pickup.finalSlot.isEmpty ? pickup.slot : pickup.finalSlot,
      },
      'pickerDetails': {
        'name': 'Scrap Uncle Picker', // Replace with actual picker name
        'id': 'PID-001', // Replace with actual picker ID
        'phoneNo': '123456789', // Replace with actual picker phone
      },
      'itemsCollected':
          currentPickupState.itemsData
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
      'declaration': 'I confirm that the above items have been collected.',
    };

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

  // Handle completing the pickup
  void _handleCompletePickup(
    BuildContext context,
    WidgetRef ref,
    Pickup currentPickupState,
    Pickup pickup,
  ) {
    if (currentPickupState.itemsData.isEmpty) {
      return;
    }

    ref.read(currentPickupProvider.notifier).setCompleted();

    CustomSnackBar.show(
      ref: ref,
      message: "Successfuly completed the pickup of customer ${pickup.name}",
      type: SnackBarType.success,
    );

    /// For now (making the call for offline sync)
    // SyncService().manualCall(ref: ref);
    Navigator.pop(context);
  }

  // Build items list content
  Widget _buildItemsList(
    Pickup currentPickupState,
    CustomColorData colorData,
    CustomSizeData sizeData,
    double height,
    double width,
    bool iscompleted,
  ) {
    if (currentPickupState.itemsData.isNotEmpty) {
      return SizedBox(
        height: height * .3,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.02,
            vertical: height * 0.01,
          ),
          itemCount: currentPickupState.itemsData.length,
          itemBuilder: (context, index) {
            Item item = currentPickupState.itemsData[index];
            return ItemDisplayCard(item: item, isStatic: iscompleted);
          },
        ),
      );
    } else {
      return Column(
        children: [
          Image.asset("assets/images/not_found.png", height: height * .2),
          SizedBox(height: height * 0.02),
          CustomText(
            text: "No Items have been added yet!",
            size: sizeData.medium,
            color: colorData.fontColor(.5),
            weight: FontWeight.w800,
            align: TextAlign.center,
          ),
        ],
      );
    }
  }

  // Build total price section
  Widget _buildTotalPrice(
    Pickup currentPickupState,
    CustomColorData colorData,
    CustomSizeData sizeData,
    double height,
  ) {
    if (currentPickupState.itemsData.isNotEmpty) {
      return Column(
        children: [
          SizedBox(height: height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  CustomText(
                    text: "Total Price:",
                    color: colorData.fontColor(.6),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: height * 0.01),
                  CustomText(
                    text: "Rs: ${currentPickupState.totalPrice}",
                    color: colorData.fontColor(.9),
                    size: sizeData.superLarge,
                    weight: FontWeight.w900,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // Build print receipt button
  Widget _buildPrintReceiptButton(
    BuildContext context,
    WidgetRef ref,
    Pickup currentPickupState,
    Pickup pickup,
    CustomColorData colorData,
    CustomSizeData sizeData,
    double height,
    double width,
    double aspectRatio,
  ) {
    return Center(
      child: Opacity(
        opacity: currentPickupState.itemsData.isEmpty ? .5 : 1,
        child: CustomInkWell(
          onPressed: () async {
            await _handlePrintReceipt(
              context,
              ref,
              pickup,
              currentPickupState,
              colorData,
              width,
            );
          },
          borderRadius: 50,
          splashColor:
              currentPickupState.itemsData.isEmpty
                  ? Colors.transparent
                  : colorData.fontColor(.5),
          margin: EdgeInsets.only(bottom: height * 0.05, top: height * .03),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: aspectRatio * 24,
              horizontal: aspectRatio * 36,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colorData.fontColor(.1), width: 1.5),
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [
                  colorData.secondaryColor(.4),
                  colorData.secondaryColor(1),
                ],
              ),
            ),
            child: CustomText(
              text: "Print receipt",
              size: sizeData.superHeader,
              weight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // Build complete pickup button
  Widget _buildCompletePickupButton(
    BuildContext context,
    WidgetRef ref,
    Pickup currentPickupState,
    Pickup pickup,
    CustomColorData colorData,
    CustomSizeData sizeData,
    double height,
    double aspectRatio,
  ) {
    return Center(
      child: Opacity(
        opacity: currentPickupState.itemsData.isEmpty ? .5 : 1,
        child: CustomInkWell(
          onPressed:
              () => _handleCompletePickup(
                context,
                ref,
                currentPickupState,
                pickup,
              ),
          borderRadius: 50,
          splashColor:
              currentPickupState.itemsData.isEmpty
                  ? Colors.transparent
                  : colorData.fontColor(.5),
          margin: EdgeInsets.only(bottom: height * 0.05, top: height * .03),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: aspectRatio * 24,
              horizontal: aspectRatio * 36,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colorData.fontColor(.1), width: 1.5),
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [
                  colorData.secondaryColor(.4),
                  colorData.secondaryColor(1),
                ],
              ),
            ),
            child: CustomText(
              text: "Complete Pickup",
              size: sizeData.superHeader,
              weight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    (Pickup?, bool) currentPickupProviderState = ref.watch(
      currentPickupProvider,
    );
    Pickup currentPickupState = currentPickupProviderState.$1!;
    bool isLocalCompleted = currentPickupProviderState.$2;
    bool isGlobalCompleted = currentPickupState.isCompleted;
    bool isCompleted = isLocalCompleted || isGlobalCompleted;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            left: width * 0.04,
            right: width * 0.04,
            top: height * 0.02,
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: CustomText(
                      text: isCompleted ? "Pickup Completed" : "Update Pickup",
                      size: sizeData.superLarge,
                      weight: FontWeight.w900,
                      color: isCompleted ? Colors.green : null,
                      height: 1.5,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: CustomBackButton(
                      onPressed:
                          () =>
                              ref.read(currentPickupProvider.notifier).close(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        CustomText(
                          text: "Contact the customer by :",
                          align: TextAlign.center,
                          color: colorData.fontColor(.5),
                          weight: FontWeight.w800,
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            WhatsAppButton(
                              customerNo: currentPickupState.mobileNo,
                              needHintText: true,
                              disable: isCompleted,
                            ),
                            PhoneCallButton(
                              customerNo: currentPickupState.mobileNo,
                              needHintText: true,
                              disable: isCompleted,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),

                    // Customer information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PickupInfoTile(
                          hintText: "Customer Name: ",
                          text: currentPickupState.name,
                        ),
                        PickupInfoTile(
                          hintText: "Pickup Slot: ",
                          text:
                              currentPickupState.finalSlot.isEmpty
                                  ? currentPickupState.slot
                                  : currentPickupState.finalSlot,
                        ),
                        PickupInfoTile(
                          hintText: "Expected Weight: ",
                          text: currentPickupState.expectedWeight,
                        ),
                        PickupInfoTile(
                          hintText: "Address: ",
                          text: currentPickupState.address,
                        ),
                        PickupInfoTile(
                          hintText: "Area: ",
                          text:
                              "${currentPickupState.area}, pin: ${currentPickupState.pincode}",
                        ),
                        PickupInfoTile(
                          hintText: "Description: ",
                          text: currentPickupState.description,
                        ),
                        Row(
                          children: [
                            CustomText(
                              text: "Location :",
                              color: colorData.fontColor(.6),
                              weight: FontWeight.w700,
                            ),
                            LocationMapButton(
                              latitude: double.parse(
                                currentPickupState.coordinates[0],
                              ),
                              longitude: double.parse(
                                currentPickupState.coordinates[1],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Items list header
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "Items List: ",
                          size: sizeData.superLarge,
                          weight: FontWeight.w900,
                          color: colorData.fontColor(.6),
                        ),
                        GradientButton(
                          disabled: isCompleted,
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddItemPage(),
                                ),
                              ),
                          text: "Add Item +",
                          color: Colors.blue,
                        ),
                      ],
                    ),

                    // Items list content
                    SizedBox(height: height * 0.02),
                    _buildItemsList(
                      currentPickupState,
                      colorData,
                      sizeData,
                      height,
                      width,
                      isCompleted,
                    ),

                    // Total price
                    _buildTotalPrice(
                      currentPickupState,
                      colorData,
                      sizeData,
                      height,
                    ),

                    // Print receipt or Complete pickup button
                    if (isCompleted)
                      _buildPrintReceiptButton(
                        context,
                        ref,
                        currentPickupState,
                        currentPickupState,
                        colorData,
                        sizeData,
                        height,
                        width,
                        aspectRatio,
                      ),

                    if (!isCompleted)
                      _buildCompletePickupButton(
                        context,
                        ref,
                        currentPickupState,
                        currentPickupState,
                        colorData,
                        sizeData,
                        height,
                        aspectRatio,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
