import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../components/common/text.component.dart';
import '../../../utilities/theme/color_data.dart';
import '../../../utilities/theme/size_data.dart';
import '../providers/navigation.provider.dart';
import '../views/home.page.dart';
// import '../views/home.page.dart';

class Navigation extends ConsumerStatefulWidget {
  const Navigation({super.key});

  @override
  ConsumerState<Navigation> createState() => _NavigationState();
}

class _NavigationState extends ConsumerState<Navigation> {
  void setIndex(int index) {
    ref.read(navigationProvider.notifier).setIndex(index);
  }

  List<Widget> pages = [
    HomePage(),
    Container(color: Colors.blueAccent),
    Container(color: Colors.yellowAccent),
  ];
  List<NavBarItem> navBarItems = [
    NavBarItem(icon: Symbols.home_filled_rounded, title: "Home"),
    NavBarItem(icon: Symbols.schedule_rounded, title: "Schedule"),
    NavBarItem(icon: Symbols.hail_rounded, title: "Pickups"),
  ];

  @override
  Widget build(BuildContext context) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    int index = ref.watch(navigationProvider);

    return Scaffold(
      backgroundColor: colorData.backgroundColor(),
      bottomNavigationBar: Container(
        height: sizeData.height * 0.08,
        decoration: BoxDecoration(
          color: colorData.backgroundColor(),
          boxShadow: [
            BoxShadow(
              color: colorData.secondaryColor(0.8),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
              navBarItems.map((item) {
                bool isSelected = navBarItems.indexOf(item) == index;
                return GestureDetector(
                  onTap: () => setIndex(navBarItems.indexOf(item)),
                  child: Container(
                    width: sizeData.width * 0.225,
                    color: Colors.transparent,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        key: ValueKey(
                          isSelected ? '${item.title}_selected' : item.title,
                        ), // Unique key for animation
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            fill: 1,
                            weight: 700,
                            grade: 200,
                            size: sizeData.aspectRatio * 58,
                            color:
                                isSelected
                                    ? colorData.highlightColor()
                                    : colorData.inactiveColor(),
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            text: item.title,
                            size: sizeData.verySmall,
                            weight: FontWeight.bold,
                            color:
                                isSelected
                                    ? colorData.highlightColor()
                                    : colorData.inactiveColor(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            top: sizeData.height * .02,
            left: sizeData.width * .04,
            right: sizeData.width * .04,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: IndexedStack(index: index, children: pages),
          ),
        ),
      ),
    );
  }
}

class NavBarItem {
  final String title;
  final dynamic icon;

  NavBarItem({required this.title, required this.icon});

  NavBarItem copyWith({String? title, dynamic icon}) {
    return NavBarItem(title: title ?? this.title, icon: icon ?? this.icon);
  }
}
