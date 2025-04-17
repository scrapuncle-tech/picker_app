import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../models/auth_state.model.dart';
import '../../models/picker.entity.dart';
import '../../providers/auth.provider.dart';
import '../../utilities/theme/color_data.dart';
import '../../utilities/theme/size_data.dart';
import '../../views/profile_page.dart';
import '../common/text.component.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    AuthState authState = ref.watch(authProvider);
    Picker picker = authState.pickerData!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Hi 👋, ${picker.name}",
                size: sizeData.superLarge,
                color: colorData.fontColor(),
              ),
              SizedBox(height: sizeData.height * .008),
              Row(
                children: [
                  CustomText(
                    text: "Welcome to ",
                    size: sizeData.medium,
                    color: colorData.fontColor(.6),
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0XFF52B788), Color(0XFF2D6A4F)],
                          ).createShader(bounds),
                      child: CustomText(
                        text: "Scrapuncle",
                        size: sizeData.subHeader,
                        color: Colors.white,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: sizeData.aspectRatio * 80,
          width: sizeData.aspectRatio * 80,
          margin: EdgeInsets.only(right: sizeData.width * .04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorData.secondaryColor(),
          ),
          child: Icon(
            Symbols.notifications_rounded,
            fill: 1,
            grade: 200,
            weight: 700,
            color: colorData.fontColor(.6),
            size: sizeData.aspectRatio * 50,
          ),
        ),
        GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ),
          child: Container(
            height: sizeData.aspectRatio * 80,
            width: sizeData.aspectRatio * 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorData.highlightColor(),
            ),
          ),
        ),
      ],
    );
  }
}
