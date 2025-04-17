import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GradientBorderChip extends StatefulWidget {
  const GradientBorderChip({
    super.key,
    required this.context,
    required this.colors,
    this.borderThickness,
    this.width,
    this.suffix,
    this.prefix,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
  });

  final Widget context;
  final List<Color> colors;
  final double? borderThickness;
  final double? width;
  final Widget? suffix;
  final Widget? prefix;
  final double? borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  @override
  State<GradientBorderChip> createState() => _GradientBorderChipState();
}

class _GradientBorderChipState extends State<GradientBorderChip> {
  double value = Random().nextDouble();
  late Timer periodic;

  @override
  void initState() {
    super.initState();
    periodic = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        value < 1 ? value += 0.0001 : value = 0;
      });
    });
  }

  @override
  void dispose() {
    periodic.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return Container(
      margin: EdgeInsets.only(right: width * .04),
      padding: EdgeInsets.all(widget.borderThickness ?? 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 50),
        gradient: SweepGradient(
          colors: widget.colors,
          transform: GradientRotation(360 * value),
        ),
      ),
      child: Container(
        width: widget.width,
        padding:
            widget.padding ??
            EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: aspectRatio * 6,
            ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 50),
          color: widget.backgroundColor ?? Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.prefix ?? const SizedBox(),
            widget.context,
            widget.suffix ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
