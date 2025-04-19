import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import 'custom_inkwell.component.dart';
import 'custom_snackbar.component.dart';
import 'text.component.dart';

class MapButton extends ConsumerWidget {
  final String mapLink;
  final double? lat;
  final double? lng;
  final bool needHintText;
  final bool disable;

  const MapButton({
    super.key,
    required this.mapLink,
    this.lat,
    this.lng,
    this.needHintText = false,
    this.disable = false,
  });

  void _openGoogleMaps(WidgetRef ref) async {
    final Uri url = Uri.parse(
      mapLink.isNotEmpty
          ? mapLink
          : lat != 0 || lng != 0
          ? "https://www.google.com/maps/search/?api=1&query=$lat,$lng"
          : "",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      CustomSnackBar.log(
        message: "Could not open Google Maps",
        status: SnackBarType.error,
      );
      debugPrint("Could not open Google Maps");
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
      child:
          needHintText
              ? CustomInkWell(
                onPressed: disable ? () {} : () => _openGoogleMaps(ref),
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
                        Colors.greenAccent.withAlpha(20),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomText(
                        text: "Whatsapp =>",
                        size: sizeData.subHeader,
                        weight: FontWeight.w900,
                      ),
                      SizedBox(width: aspectRatio * 16),
                      Image.asset(
                        "assets/icons/gmap.png",
                        width: aspectRatio * 80,
                        height: aspectRatio * 80,
                      ),
                    ],
                  ),
                ),
              )
              : CustomInkWell(
                splashColor: colorData.secondaryColor(1),
                onPressed: disable ? () {} : () => _openGoogleMaps(ref),
                child: Image.asset(
                  "assets/icons/gmap.png",
                  width: aspectRatio * 80,
                  height: aspectRatio * 80,
                ),
              ),
    );
  }
}
