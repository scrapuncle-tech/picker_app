import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utilities/theme/size_data.dart';
import '../common/custom_inkwell.component.dart';
import '../common/text.component.dart';

class LocationMapButton extends ConsumerWidget {
  const LocationMapButton({
    super.key,
    required this.latitude,
    required this.longitude,
  });
  final double latitude;
  final double longitude;

  void _openGoogleMaps(double latitude, double longitude) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open Google Maps");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomSizeData sizeData = CustomSizeData.from(context);

    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    return CustomInkWell(
      onPressed: () => _openGoogleMaps(latitude, longitude),
      borderRadius: 8,
      splashColor: Colors.green.withAlpha(100),
      margin: EdgeInsets.only(left: width * 0.02),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: aspectRatio * 8,
          horizontal: aspectRatio * 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green.withAlpha(160),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.green.withAlpha(80), Colors.green.withAlpha(20)],
          ),
        ),
        child: CustomText(
          text: "Open Location in Map ",
          size: sizeData.subHeader,
          weight: FontWeight.w900,
        ),
      ),
    );
  }
}
