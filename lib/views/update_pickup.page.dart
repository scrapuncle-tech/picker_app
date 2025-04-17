import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/common/custom_back_button.component.dart';
import '../components/common/custom_inkwell.component.dart';
import '../components/common/gradient_button.component.dart';
import '../components/common/text.component.dart';
import '../components/common/phone_call_button.component.dart';
import '../components/common/watsapp_button.component.dart';
import '../components/update_pickup/item_display_card.componenet.dart';
import '../components/update_pickup/location_map_button.component.dart';
import '../components/update_pickup/pickupinfo_tile.component.dart';
import '../models/item.entity.dart';
import '../models/pickup.entity.dart';
import '../providers/current_pickup.provider.dart';
import '../services/helper/receipt.service.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';
import 'add_item.page.dart';

class UpdatePickupPage extends ConsumerWidget {
  final ReceiptService _receiptService = ReceiptService();

  UpdatePickupPage({super.key});

  // Build print receipt button
  Widget _buildPrintReceiptButton(
    BuildContext context,
    WidgetRef ref,
    Pickup pickup,
    CustomColorData colorData,
    CustomSizeData sizeData,
    double height,
    double width,
    double aspectRatio,
  ) {
    return Center(
      child: Opacity(
        opacity: pickup.itemsData.isEmpty ? .5 : 1,
        child: CustomInkWell(
          onPressed: () async {
            await _receiptService.handlePrintReceipt(
              context,
              ref,
              pickup,
              colorData.secondaryColor(1),
              width,
            );
          },
          borderRadius: 50,
          splashColor:
              pickup.itemsData.isEmpty
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
    Pickup pickup,
    CustomColorData colorData,
    CustomSizeData sizeData,
    double height,
    double aspectRatio,
  ) {
    return Center(
      child: Opacity(
        opacity: pickup.itemsData.isEmpty ? .5 : 1,
        child: CustomInkWell(
          onPressed:
              () => _receiptService.completePickup(
                context,
                ref,
                pickup,
                pickup,
                () => ref.read(currentPickupProvider.notifier).setCompleted(),
              ),
          borderRadius: 50,
          splashColor:
              pickup.itemsData.isEmpty
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(currentPickupProvider.notifier).close();
        }
      },
      child: Scaffold(
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
                        text:
                            isCompleted ? "Pickup Completed" : "Update Pickup",
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
                                ref
                                    .read(currentPickupProvider.notifier)
                                    .close(),
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
                                latitude:
                                    double.tryParse(
                                      currentPickupState.coordinates.isNotEmpty
                                          ? currentPickupState.coordinates[0]
                                          : '0',
                                    ) ??
                                    0.0,
                                longitude:
                                    double.tryParse(
                                      currentPickupState.coordinates.length > 1
                                          ? currentPickupState.coordinates[1]
                                          : '0',
                                    ) ??
                                    0.0,
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
                      if (currentPickupState.itemsData.isNotEmpty)
                        SizedBox(
                          height: height * .3,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.01,
                            ),
                            itemCount: currentPickupState.itemsData.length,
                            itemBuilder: (context, index) {
                              Item item = currentPickupState.itemsData[index];
                              return ItemDisplayCard(
                                item: item,
                                isStatic: isCompleted,
                              );
                            },
                          ),
                        )
                      else
                        Column(
                          children: [
                            Image.asset(
                              "assets/images/not_found.png",
                              height: height * .2,
                            ),
                            SizedBox(height: height * 0.02),
                            CustomText(
                              text: "No Items have been added yet!",
                              size: sizeData.medium,
                              color: colorData.fontColor(.5),
                              weight: FontWeight.w800,
                              align: TextAlign.center,
                            ),
                          ],
                        ),

                      // Total price
                      if (currentPickupState.itemsData.isNotEmpty)
                        Column(
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
                                      text:
                                          "Rs: ${currentPickupState.totalPrice}",
                                      color: colorData.fontColor(.9),
                                      size: sizeData.superLarge,
                                      weight: FontWeight.w900,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                      // Print receipt or Complete pickup button
                      if (isCompleted)
                        _buildPrintReceiptButton(
                          context,
                          ref,
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
      ),
    );
  }
}
