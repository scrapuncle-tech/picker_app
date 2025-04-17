import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import '../auth_shifter.dart';
import '../components/common/text.component.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    // double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double height = MediaQuery.of(context).size.height;
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    // double width = MediaQuery.of(context).size.width;

    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splashIconSize: height,
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/icons/logo.png", height: height * .185),
          SizedBox(height: height * .02),
          CustomText(
            text: "Scrapuncle",
            color: Colors.green,
            weight: FontWeight.bold,
            size: 65 * aspectRatio,
          ),
          SizedBox(height: height * .06),
        ],
      ),
      duration: 2000,
      nextScreen: AuthShifter(),
    );
  }
}
