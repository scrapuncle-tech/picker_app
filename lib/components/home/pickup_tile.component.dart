import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/pickup.entity.dart';
import '../../providers/current_pickup.provider.dart';
import '../../services/basic.service.dart';
import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../../views/update_pickup.page.dart';
import '../common/custom_inkwell.component.dart';
import '../common/map_button.component.dart';
import '../common/text.component.dart';
import '../common/phone_call_button.component.dart';
// import '../common/watsapp_button.component.dart';

class PickupTile extends ConsumerWidget {
  const PickupTile({
    super.key,
    required this.pickup,
    this.localCompletionState = false,
  });

  final Pickup pickup;
  final bool localCompletionState;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    bool isCompleted = localCompletionState || pickup.isCompleted;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: isCompleted ? 1 : 0.8,
          child: CustomInkWell(
            onPressed: () {
              // if (isLocalCompleted && !completionState) return;
              ref
                  .read(currentPickupProvider.notifier)
                  .init(pickup: pickup, isLocal: localCompletionState);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatePickupPage()),
              );
            },
            splashColor: colorData.secondaryColor(1),
            margin: EdgeInsets.only(
              bottom: height * .02,
              top: localCompletionState ? height * .03 : height * 0.01,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: aspectRatio * 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorData.secondaryColor(.8),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
                color: colorData.secondaryColor(.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: width * 0.02),
                              padding: EdgeInsets.all(aspectRatio * 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: colorData.backgroundColor(1),
                                border: Border.all(
                                  color: colorData.secondaryColor(1),
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                              child: CustomText(
                                text: pickup.firebaseIndex.toString(),
                                weight: FontWeight.w900,
                                color: colorData.fontColor(1),
                                size: sizeData.superHeader,
                                shadowList: [
                                  Shadow(
                                    color: colorData.fontColor(1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            CustomText(
                              text: "Name: ",
                              size: sizeData.small,
                              color: colorData.fontColor(.5),
                              weight: FontWeight.bold,
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: CustomText(
                                text: pickup.name,
                                size: sizeData.subHeader,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: aspectRatio * 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomText(
                              text: "Slot: ",
                              size: sizeData.small,
                              color: colorData.fontColor(.5),
                              weight: FontWeight.bold,
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: CustomText(
                                text:
                                    pickup.finalSlot.isEmpty
                                        ? pickup.slot
                                        : pickup.finalSlot,
                                size: sizeData.medium,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: aspectRatio * 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomText(
                              text: "Expected Weight: ",
                              size: sizeData.small,
                              color: colorData.fontColor(.5),
                              weight: FontWeight.bold,
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: CustomText(
                                text: pickup.expectedWeight,
                                size: sizeData.medium,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: aspectRatio * 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                              text: "Status: ",
                              size: sizeData.small,
                              color: colorData.fontColor(.6),
                              weight: FontWeight.bold,
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: CustomText(
                                text:
                                    pickup.isCompleted
                                        ? "COMPLETED"
                                        : pickup.status,
                                size: sizeData.medium,
                                weight: FontWeight.bold,
                                color: getStatusColor(
                                  pickup.isCompleted
                                      ? "COMPLETED"
                                      : pickup.status,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     CustomText(
                        //       text: "Address: ",
                        //       size: sizeData.small,
                        //       color: colorData.fontColor(.6),
                        //       weight: FontWeight.bold,
                        //     ),
                        //     SizedBox(width: width * .01),
                        //     Expanded(
                        //       child: CustomText(
                        //         text:
                        //             "${pickup.address}, ${pickup.area}, Pincode: ${pickup.pincode}",
                        //         maxLine: 3,
                        //         height: 1.5,
                        //       ),
                        //     )
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PhoneCallButton(
                        customerNo: pickup.mobileNo,
                        disable: isCompleted,
                      ),
                      SizedBox(height: height * 0.02),
                      // WhatsAppButton(
                      //   customerNo: pickup.mobileNo,
                      //   disable: isLocalCompleted,
                      // ),
                      MapButton(
                        mapLink: pickup.mapLink,
                        lat: double.tryParse(pickup.coordinates[0]),
                        lng: double.tryParse(pickup.coordinates[1]),
                        disable: isCompleted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (localCompletionState)
          Positioned(
            top: 6,
            left: 0,
            child: CustomText(
              text: "Completed and waiting for online sync!",
              color: Colors.red,
              weight: FontWeight.w800,
              size: sizeData.regular,
              align: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
