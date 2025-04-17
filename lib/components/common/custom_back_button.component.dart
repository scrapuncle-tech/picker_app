import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import 'custom_inkwell.component.dart';

class CustomBackButton extends ConsumerWidget {
  const CustomBackButton({super.key, this.onPressed});
  final Function? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    return CustomInkWell(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        if (onPressed != null) onPressed!();
      },
      borderRadius: sizeData.aspectRatio * 20,
      child: Container(
        padding: EdgeInsets.all(sizeData.aspectRatio * 10),
        decoration: BoxDecoration(
          border: Border.all(color: colorData.secondaryColor(.8), width: 2),
          borderRadius: BorderRadius.circular(sizeData.aspectRatio * 20),
          color: colorData.secondaryColor(.6), // Move color here
        ),
        child: Icon(
          Symbols.arrow_back_ios_new_rounded,
          fill: 1,
          grade: 200,
          weight: 700,
          color: colorData.fontColor(.8),
        ),
      ),
    );
  }
}
