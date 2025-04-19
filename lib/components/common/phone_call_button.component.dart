import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../models/auth_state.model.dart';
import '../../providers/auth.provider.dart';
import '../../utilities/static_data.dart';
import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import 'custom_inkwell.component.dart';
import 'custom_snackbar.component.dart';
import 'text.component.dart';

class PhoneCallButton extends ConsumerWidget {
  final String customerNo;
  final bool needHintText;
  final bool disable;

  const PhoneCallButton({
    super.key,
    required this.customerNo,
    this.needHintText = false,
    this.disable = false,
  });

  void _handleXmlResponse(String responseText, WidgetRef ref) {
    if (responseText.contains('<Status>in-progress</Status>')) {
      debugPrint("✅ Call initiated successfully");
      CustomSnackBar.log(
        message: 'Call started.',
        status: SnackBarType.success,
      );
    } else if (responseText.contains('NDNC')) {
      CustomSnackBar.log(
        message: 'Number is on NDNC list.',
        status: SnackBarType.error,
      );
    } else {
      final errorMessage =
          RegExp(
            r'<Message>(.*?)</Message>',
          ).firstMatch(responseText)?.group(1) ??
          'Could not start call.';
      CustomSnackBar.log(message: errorMessage, status: SnackBarType.error);
    }
  }

  void _handleJsonResponse(String responseBody, WidgetRef ref) {
    try {
      final Map<String, dynamic> responseData = json.decode(responseBody);
      if (responseData['Call'] != null) {
        debugPrint("✅ Call initiated successfully");
        CustomSnackBar.log(
          message: 'Call started.',
          status: SnackBarType.success,
        );
      } else {
        CustomSnackBar.log(
          message: 'Call could not be started.',
          status: SnackBarType.error,
        );
      }
    } catch (_) {
      CustomSnackBar.log(
        message: 'Invalid call response.',
        status: SnackBarType.error,
      );
    }
  }

  Future<void> _initiateExotelCall({
    required String customerNo,
    required String pickerPhoneNo,
    required WidgetRef ref,
  }) async {
    final Uri url = Uri.parse(
      'https://$exotelApiKey:$exotelApiToken@api.exotel.com/v1/Accounts/$exotelSid/Calls/connect',
    );

    final String formattedFromNumber =
        pickerPhoneNo.startsWith('+91') ? pickerPhoneNo : "+91$pickerPhoneNo";
    final String formattedToNumber =
        customerNo.startsWith('+91') ? customerNo : "+91$customerNo";

    final Map<String, String> body = {
      'From': formattedFromNumber,
      'To': formattedToNumber,
      'CallerId': callerId,
    };

    try {
      final http.Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      final String responseText = response.body.trim();

      if (responseText.startsWith('<?xml')) {
        _handleXmlResponse(responseText, ref);
      } else {
        _handleJsonResponse(response.body, ref);
      }
    } catch (_) {
      CustomSnackBar.log(
        message: 'Could not connect. Try again.',
        status: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    // double height = sizeData.height;
    // double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    AuthState authState = ref.watch(authProvider);

    return Opacity(
      opacity: disable ? 0.5 : 1.0,
      child:
          needHintText
              ? CustomInkWell(
                onPressed:
                    () =>
                        disable
                            ? null
                            : _initiateExotelCall(
                              customerNo: customerNo,
                              pickerPhoneNo: authState.pickerData!.phoneNo,
                              ref: ref,
                            ),
                borderRadius: 12,
                splashColor: Colors.blueAccent.withAlpha(100),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: aspectRatio * 12,
                    horizontal: aspectRatio * 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blueAccent.withAlpha(160),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withAlpha(80),
                        Colors.blueAccent.withAlpha(20),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomText(
                        text: "Phone call =>",
                        size: sizeData.subHeader,
                        weight: FontWeight.w900,
                      ),
                      SizedBox(width: aspectRatio * 16),
                      Image.asset(
                        "assets/icons/phone.png",
                        width: aspectRatio * 80,
                        height: aspectRatio * 80,
                      ),
                    ],
                  ),
                ),
              )
              : CustomInkWell(
                splashColor: colorData.secondaryColor(1),
                onPressed:
                    () =>
                        disable
                            ? null
                            : _initiateExotelCall(
                              customerNo: customerNo,
                              pickerPhoneNo: authState.pickerData!.phoneNo,
                              ref: ref,
                            ),
                child: Image.asset(
                  "assets/icons/phone.png",
                  width: aspectRatio * 80,
                  height: aspectRatio * 80,
                ),
              ),
    );
  }
}
