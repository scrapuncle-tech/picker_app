import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../common/custom_inkwell.component.dart';
import '../common/gradient_button.component.dart';
import '../common/text.component.dart';

class BluetoothDeviceDialog {
  static Future<BluetoothDevice?> showDeviceSelectionDialog({
    required BuildContext context,
    required WidgetRef ref,
    required List<BluetoothDevice> devices,
  }) async {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;

    BluetoothDevice? selectedDevice;

    return await showDialog<BluetoothDevice?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Column(
              children: [
                CustomText(
                  text: "Select a Bluetooth Device",
                  size: sizeData.superHeader,
                  weight: FontWeight.w900,
                  color: colorData.fontColor(.8),
                ),
                SizedBox(height: height * 0.01),
                Divider(color: colorData.fontColor(.2), thickness: 1),
              ],
            ),
            content: SizedBox(
              width: width * 0.8,
              height: height * 0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (devices.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bluetooth_disabled,
                              size: 50,
                              color: colorData.fontColor(.5),
                            ),
                            SizedBox(height: height * 0.02),
                            CustomText(
                              text: "No Bluetooth devices found",
                              color: colorData.fontColor(.5),
                              weight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final isSelected =
                              selectedDevice?.remoteId == device.remoteId;

                          return CustomInkWell(
                            onPressed: () {
                              setState(() {
                                selectedDevice = device;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? colorData.secondaryColor(1)
                                      : colorData.fontColor(.2),
                                  width: 1.5,
                                ),
                                color: isSelected
                                    ? colorData.secondaryColor(.1)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: device.name.isEmpty
                                              ? "Unknown Device"
                                              : device.name,
                                          weight: FontWeight.w700,
                                          color: colorData.fontColor(.8),
                                        ),
                                        SizedBox(height: 4),
                                        CustomText(
                                          text: "ID: ${device.remoteId}",
                                          size: sizeData.small,
                                          color: colorData.fontColor(.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: colorData.secondaryColor(1),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: CustomText(
                      text: "Cancel",
                      color: colorData.fontColor(.6),
                      weight: FontWeight.w700,
                    ),
                  ),
                  GradientButton(
                    disabled: selectedDevice == null,
                    onPressed: () {
                      Navigator.of(context).pop(selectedDevice);
                    },
                    text: "Connect",
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
