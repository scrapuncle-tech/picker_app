import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import 'custom_inkwell.component.dart';
import 'text.component.dart';

class WhatsAppButton extends ConsumerWidget {
  final String customerNo;
  final bool needHintText;
  final bool disable;

  const WhatsAppButton(
      {super.key,
      required this.customerNo,
      this.needHintText = false,
      this.disable = false});

  void _launchWhatsApp() async {
    final url = Uri.parse(
        'https://wa.me/+91$customerNo?text=Greetings%20from%20ScrapUncle!%0aThe%20team%20is%20out%20for%20your%20scrap%20pickup.%0aPlease%20share%20your%20Pickup%20location.%0aThank%20you');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    // double height = sizeData.height;
    // double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    return Opacity(
      opacity: disable ? 0.5 : 1,
      child: needHintText
          ? CustomInkWell(
              onPressed: disable ? () {} : _launchWhatsApp,
              borderRadius: 12,
              splashColor: Colors.greenAccent.withAlpha(100),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: aspectRatio * 12,
                  horizontal: aspectRatio * 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.greenAccent.withAlpha(160),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent.withAlpha(80),
                      Colors.greenAccent.withAlpha(20)
                    ],
                  ),
                ),
                child: Row(children: [
                  CustomText(
                    text: "Whatsapp",
                    size: sizeData.subHeader,
                    weight: FontWeight.w900,
                  ),
                  SizedBox(width: aspectRatio * 16),
                  Image.asset(
                    "assets/icons/whatsapp.png",
                    width: aspectRatio * 80,
                    height: aspectRatio * 80,
                  ),
                ]),
              ),
            )
          : CustomInkWell(
              splashColor: colorData.secondaryColor(1),
              onPressed: disable ? () {} : _launchWhatsApp,
              child: Image.asset(
                "assets/icons/whatsapp.png",
                width: aspectRatio * 80,
                height: aspectRatio * 80,
              ),
            ),
    );
  }
}
