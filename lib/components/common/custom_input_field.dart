import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';

class CustomInputField extends ConsumerWidget {
  const CustomInputField({
    super.key,
    this.controller,
    required this.hintText,
    required this.inputType,
    this.readOnly = false,
    this.visibleText = true,
    this.prefixIcon,
    this.suffixIcon,
    this.listener,
    this.initialValue,
    this.margin,
    this.borderRadius,
  });
  final TextEditingController? controller;
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType inputType;
  final bool readOnly;
  final bool visibleText;
  final Function? listener;
  final String? initialValue;
  final EdgeInsets? margin;
  final double? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);
    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    return Container(
      height: height * 0.045,
      margin: margin ?? EdgeInsets.only(top: height * 0.012),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: Border.all(
            color: colorData.secondaryColor(1),
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter),
        color: colorData.secondaryColor(.3),
      ),
      child: TextFormField(
        readOnly: readOnly,
        initialValue: initialValue,
        controller: controller,
        keyboardType: inputType,
        onChanged: (value) {
          if (listener != null) {
            listener!(value);
          }
        },
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 32 * aspectRatio,
          color: colorData.fontColor(.8),
        ),
        cursorColor: colorData.gradientColor2,
        cursorWidth: 2,
        obscureText: !visibleText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28 * aspectRatio,
            color: colorData.fontColor(.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: aspectRatio * 26),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}
