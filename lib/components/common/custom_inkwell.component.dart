import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';

class CustomInkWell extends ConsumerWidget {
  const CustomInkWell({
    super.key,
    required this.onPressed,
    required this.child,
    this.splashColor,
    this.borderRadius,
    this.margin,
  });

  final Color? splashColor;
  final double? borderRadius;
  final Function onPressed;
  final Widget child;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        borderRadius: BorderRadius.circular(
          borderRadius ?? sizeData.aspectRatio * 10,
        ),
        color: Colors.transparent,
        child: InkWell(
          splashColor: splashColor ?? colorData.fontColor(.5),
          highlightColor: splashColor ?? colorData.fontColor(.5),
          borderRadius: BorderRadius.circular(
            borderRadius ?? sizeData.aspectRatio * 10,
          ),
          onTap: () {
            onPressed();
            HapticFeedback.mediumImpact();
          },
          child: child,
        ),
      ),
    );
  }
}
