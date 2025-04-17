import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../components/common/text.component.dart';
import '../components/home/header.component.dart';
import '../components/home/pickup_tile.component.dart';
import '../models/pickup.entity.dart';
import '../models/route_info.model.dart';
import '../providers/route.provider.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    RouteInfo routeInfo = ref.watch(routeInfoProvider);

    return Column(
      children: [
        HomeHeader(),
        SizedBox(height: height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              text: "REFRESH",
              size: sizeData.subHeader,
              color: colorData.fontColor(.6),
              weight: FontWeight.w900,
            ),
            SizedBox(width: width * 0.02),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Symbols.refresh_rounded,
                size: aspectRatio * 70,
                fill: 1,
                weight: 700,
                grade: 200,
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: height * .01),
        Row(
          children: [
            CustomText(
              text: "Assigned Route:",
              size: sizeData.subHeader,
              color: colorData.fontColor(.6),
              weight: FontWeight.w900,
            ),
            SizedBox(width: width * 0.02),
            Expanded(
              child:
                  routeInfo.route != null
                      ? CustomText(
                        text: routeInfo.route!.name,
                        loadingState: routeInfo.isLoading,
                        maxLine: 2,
                        weight: FontWeight.w900,
                        size: sizeData.superHeader,
                      )
                      : CustomText(
                        text: "No route has been \nassigned yet!",
                        maxLine: 2,
                        align: TextAlign.center,
                        color: Colors.redAccent,
                      ),
            ),
          ],
        ),
        Expanded(
          flex: 3,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            itemCount: routeInfo.pickups.length,
            itemBuilder: (context, index) {
              Pickup pickup = routeInfo.pickups[index];
              return PickupTile(
                pickup: pickup,
                localCompletionState: pickup.isCompleted,
              );
            },
          ),
        ),
        if (routeInfo.completedPickups.isNotEmpty) ...[
          // SizedBox(height: height * 0.02),
          Divider(color: colorData.secondaryColor(1)),
          SizedBox(height: height * 0.02),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomText(
              text: "COMPLETED PICKUPS:",
              size: sizeData.subHeader,
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
        ],
      ],
    );
  }
}
