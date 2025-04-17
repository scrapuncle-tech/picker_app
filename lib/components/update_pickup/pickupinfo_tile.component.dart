import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../common/text.component.dart';

class PickupInfoTile extends ConsumerWidget {
  const PickupInfoTile({super.key, required this.text, required this.hintText});

  final String text;
  final String hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double width = sizeData.width;
    double height = sizeData.height;
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.0125),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomText(
            text: hintText,
            color: colorData.fontColor(.6),
            weight: FontWeight.w700,
          ),
          SizedBox(width: width * .01),
          Expanded(
            child: CustomText(
              text: text,
              size: sizeData.subHeader,
              color: colorData.fontColor(.8),
              weight: FontWeight.w900,
              maxLine: 2,
            ),
          ),
        ],
      ),
    );
  }
}
