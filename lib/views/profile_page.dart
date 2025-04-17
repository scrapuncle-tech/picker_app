import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/common/custom_back_button.component.dart';
import '../components/common/network_image.dart';
import '../components/common/text.component.dart';
import '../components/profile/profile_tile.dart';
import '../components/profile/theme_toggle.dart';
import '../models/auth_state.model.dart';
import '../models/picker.entity.dart';
import '../providers/auth.provider.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    AuthState authState = ref.read(authProvider);
    Picker pickerData = authState.pickerData!;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            left: width * 0.04,
            right: width * 0.04,
            top: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [CustomBackButton(), ThemeToggle()],
              ),
              SizedBox(height: height * 0.02),
              CustomNetworkImage(
                size: aspectRatio * 250,
                radius: width,
                // url: userData.imagePath,
                padding: aspectRatio * 8,
                backgroundColor: colorData.secondaryColor(1),
              ),
              SizedBox(height: height * 0.02),
              CustomText(
                text: pickerData.name,
                size: sizeData.header,
                weight: FontWeight.w800,
                color: colorData.fontColor(.8),
              ),
              SizedBox(height: height * 0.005),
              CustomText(
                text: pickerData.email,
                size: sizeData.regular,
                color: colorData.fontColor(.6),
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: "ASSIGNED ROUTE: ",
                    size: sizeData.regular,
                    color: colorData.fontColor(.6),
                  ),
                  SizedBox(width: width * 0.01),
                  if (pickerData.routeName.isNotEmpty)
                    CustomText(
                      text: pickerData.routeName,
                      size: sizeData.header,
                      weight: FontWeight.w800,
                      color: colorData.fontColor(.8),
                    )
                  else
                    CustomText(
                      text: "Not yet assigned",
                      size: sizeData.medium,
                      weight: FontWeight.w600,
                      color: Colors.red,
                    ),
                ],
              ),
              SizedBox(height: height * 0.05),
              ProfileTile(
                text: 'Edit Profile',
                icon: Icons.edit_outlined,
                todo: () {},
              ),
              SizedBox(height: height * 0.03),
              ProfileTile(
                text: 'Help',
                icon: Icons.help_outline_outlined,
                todo: () {},
              ),
              SizedBox(height: height * 0.03),
              ProfileTile(text: 'History', icon: Icons.history, todo: () {}),
              SizedBox(height: height * 0.03),
              ProfileTile(
                text: 'Logout',
                icon: Icons.logout_outlined,
                todo: () {
                  ref.read(authProvider.notifier).signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
