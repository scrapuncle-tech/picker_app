import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/common/text.component.dart';
import '../components/home/pickup_tile.component.dart';
import '../models/pickup.entity.dart';
import '../models/route_info.model.dart';
import '../providers/route.provider.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';

class PickupsPage extends ConsumerWidget {
  const PickupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    // double width = sizeData.width;

    RouteInfo routeInfo = ref.watch(routeInfoProvider);

    return Column(
      children: [
        if (routeInfo.completedPickups.isNotEmpty) ...[
          SizedBox(height: height * 0.02),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomText(
              text: "COMPLETED PICKUPS:",
              size: sizeData.header,
              color: colorData.fontColor(.6),
              weight: FontWeight.w900,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: height * 0.02),
              itemCount: routeInfo.completedPickups.length,
              itemBuilder: (context, index) {
                Pickup pickup = routeInfo.completedPickups[index];
                return PickupTile(pickup: pickup);
              },
            ),
          ),
        ] else ...[
          SizedBox(height: height * 0.02),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomText(
              text: "NO COMPLETED PICKUPS",
              size: sizeData.header,
              color: colorData.fontColor(.6),
              weight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }
}
