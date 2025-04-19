import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../models/item.entity.dart';
import '../../providers/current_pickup.provider.dart';
import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../common/network_image.dart';
import '../common/text.component.dart';

class ItemDisplayCard extends ConsumerWidget {
  const ItemDisplayCard({
    super.key,
    required this.item,
    required this.isStatic,
  });
  final Item item;
  final bool isStatic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: height * 0.03),
          padding: EdgeInsets.all(aspectRatio * 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorData.secondaryColor(1),
              width: 2,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            color: colorData.secondaryColor(.2),
          ),
          child: Row(
            children: [
              item.imageUrls != null && item.imageUrls!.isNotEmpty
                  ? CustomNetworkImage(
                    size: width * .2,
                    radius: 12,
                    url: item.imageUrls!.first,
                  )
                  : item.localImagePaths != null &&
                      item.localImagePaths!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.localImagePaths!.first),
                      width: width * .2,
                      height: width * .2,
                      fit: BoxFit.cover,
                    ),
                  )
                  : SizedBox(),
              SizedBox(width: width * 0.02),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: item.product.name,
                      size: sizeData.header,
                      weight: FontWeight.w900,
                    ),
                    SizedBox(height: aspectRatio * 8),
                    Row(
                      children: [
                        CustomText(
                          text: "Price: ",
                          size: sizeData.small,
                          weight: FontWeight.w600,
                          color: colorData.fontColor(.5),
                        ),
                        CustomText(
                          text:
                              item.customPrice?.toString() ??
                              item.product.price.toString(),
                          size: sizeData.regular,
                          weight: FontWeight.w800,
                          color: colorData.fontColor(.8),
                        ),
                        Spacer(),
                        CustomText(
                          text:
                              "(${item.customPrice != null ? "Custom" : "Actual"})",
                          size: sizeData.small,
                          weight: FontWeight.w700,
                          color: colorData.fontColor(.6),
                        ),
                      ],
                    ),
                    SizedBox(height: aspectRatio * 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "${item.weight} kg,  ${item.quantity} unit",
                          size: sizeData.medium,
                          weight: FontWeight.w900,
                          color: colorData.fontColor(.8),
                        ),
                        CustomText(
                          text: "₹ ${item.totalPrice}",
                          size: sizeData.subHeader,
                          weight: FontWeight.w900,
                          color: colorData.fontColor(.9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isStatic)
          Positioned(
            top: -aspectRatio * 10,
            right: -aspectRatio * 10,
            child: IconButton(
              onPressed:
                  () => ref
                      .read(currentPickupProvider.notifier)
                      .removeItem(item: item),
              icon: Icon(
                Symbols.delete,
                fill: 1,
                weight: 700,
                grade: 200,
                color: Colors.red,
                size: aspectRatio * 50,
              ),
            ),
          ),
      ],
    );
  }
}
