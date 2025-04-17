import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_shifter.dart';
import '../components/common/gradient_border_chip.component.dart';
import '../components/common/text.component.dart';
import '../components/on_boarding/navigator_indicator.component.dart';
import '../utilities/static_data.dart';
import '../utilities/theme/size_data.dart';

class OnBoarding extends ConsumerStatefulWidget {
  const OnBoarding({super.key});

  @override
  ConsumerState<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends ConsumerState<OnBoarding> {
  int currentView = 0; // Tracks the current page view
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0); // Initialize PageController
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose PageController to free resources
    super.dispose();
  }

  // Set 'isFirstTimeView' to false and navigate to AuthShifter
  Future<void> setIsFirstTimeView() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isFirstTimeView', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthShifter()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomSizeData sizeData = CustomSizeData.from(context);

    double width = sizeData.width;
    double height = sizeData.height;
    double aspectRatio = sizeData.aspectRatio;

    // Helper function to get font color with opacity
    Color fontColor(double opacity) => Colors.white.withOpacity(opacity);

    List<MapEntry<String, String>> onBoardingData = obTextMap.entries.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.04,
          ),
          child: Column(
            children: [
              // Navigator indicator
              Expanded(
                flex: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (index) => NavigatorIndicator(
                      width: width,
                      height: height,
                      index: index,
                      isSelected: currentView == index,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              // Page view for onboarding screens
              Expanded(
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: controller,
                  itemCount: onBoardingData.length,
                  onPageChanged: (int value) {
                    setState(() {
                      currentView = value;
                    });
                  },
                  itemBuilder:
                      (context, index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * .03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.asset(
                                obImagePaths[index],
                                fit: BoxFit.cover,
                                height: height * .325,
                              ),
                            ),
                            Spacer(),
                            ShaderMask(
                              shaderCallback:
                                  (bounds) => LinearGradient(
                                    colors: [
                                      Color(0XFFDEC4F4),
                                      Color(0XFF325EE6),
                                    ],
                                  ).createShader(bounds),
                              child: CustomText(
                                text: onBoardingData[index].key,
                                color: Colors.white,
                                size: 68 * aspectRatio,
                                maxLine: 2,
                              ),
                            ),
                            SizedBox(height: height * .04),
                            CustomText(
                              text: onBoardingData[index].value,
                              maxLine: 3,
                              color: fontColor(.9),
                              size: 36 * aspectRatio,
                              weight: FontWeight.w500,
                              height: 1.5,
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                ),
              ),
              // 'Get Started' button
              GestureDetector(
                onTap: setIsFirstTimeView,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * .2),
                  child: GradientBorderChip(
                    context: CustomText(
                      text: "GET STARTED",
                      color: Colors.white,
                      size: 36 * aspectRatio,
                    ),
                    backgroundColor: Colors.black,
                    borderThickness: 2,
                    colors: [Color(0XFFDEC4F4), Color(0XFF325EE6)],
                    padding: EdgeInsets.symmetric(vertical: height * .015),
                  ),
                ),
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
