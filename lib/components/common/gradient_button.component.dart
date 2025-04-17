import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/theme/size_data.dart';
import 'custom_inkwell.component.dart';
import 'text.component.dart';

class GradientButton extends ConsumerWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    this.borderRadius = 50,
    this.child,
    this.horizontalPadding,
    this.disabled = false,
  });
  final Function onPressed;
  final String text;
  final Color color;
  final double borderRadius;
  final Widget? child;
  final double? horizontalPadding;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomSizeData sizeData = CustomSizeData.from(context);

    double aspectRatio = sizeData.aspectRatio;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Center(
        child: CustomInkWell(
          onPressed: !disabled ? onPressed : () {},
          borderRadius: borderRadius,
          splashColor: color.withAlpha(100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: EdgeInsets.symmetric(
              vertical: aspectRatio * 12,
              horizontal: horizontalPadding ?? aspectRatio * 26,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withAlpha(160),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                colors: [color.withAlpha(80), color.withAlpha(20)],
              ),
            ),
            child: child ??
                CustomText(
                  text: text,
                  size: sizeData.header,
                  weight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}
