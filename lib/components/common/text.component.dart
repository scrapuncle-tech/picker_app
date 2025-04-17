import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';

class CustomText extends ConsumerWidget {
  final String text;
  final FontWeight? weight;
  final double? size;
  final Color? color;
  final double height;
  final TextAlign align;
  final int maxLine;
  final bool loadingState;
  final double length;
  final List<Shadow>? shadowList;
  final bool shimmerText;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final String? fontFamily;

  const CustomText({
    super.key,
    required this.text,
    this.weight,
    this.size,
    this.color,
    this.height = 0,
    this.align = TextAlign.start,
    this.maxLine = 1,
    this.loadingState = false,
    this.length = 0.1,
    this.shadowList,
    this.shimmerText = false,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomSizeData sizeData = CustomSizeData.from(context);
    CustomColorData colorData = CustomColorData.from(ref);

    double width = sizeData.width;

    return !loadingState
        ? shimmerText
            ? Shimmer.fromColors(
              baseColor: colorData.fontColor(.3),
              highlightColor: colorData.secondaryColor(),
              child: Text(
                text,
                textAlign: align,
                maxLines: maxLine,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: size ?? sizeData.regular,
                  fontWeight: weight ?? FontWeight.w600,
                  color: colorData.fontColor(),
                  height: height,
                  fontFamily: fontFamily,
                  decoration: decoration,
                  shadows: shadowList,
                  decorationColor: decorationColor,
                  decorationStyle: decorationStyle,
                  decorationThickness: decorationThickness,
                ),
              ),
            )
            : Text(
              text,
              textAlign: align,
              maxLines: maxLine,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size ?? sizeData.regular,
                fontWeight: weight ?? FontWeight.w600,
                color: color ?? colorData.fontColor(.8),
                height: height,
                decoration: decoration,
                fontFamily: fontFamily,
                shadows: shadowList,
                decorationColor: decorationColor,
                decorationStyle: decorationStyle,
                decorationThickness: decorationThickness,
              ),
            )
        : Shimmer.fromColors(
          baseColor: colorData.backgroundColor(),
          highlightColor: colorData.secondaryColor(),
          child: Container(
            height: size,
            width: length * width,
            decoration: BoxDecoration(
              color: colorData.fontColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
  }
}
