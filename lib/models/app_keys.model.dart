import 'package:flutter/material.dart';

class AppKeys {
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  GlobalKey<NavigatorState> navigatorKey;
  GlobalKey restartKey;

  AppKeys({
    required this.scaffoldMessengerKey,
    required this.navigatorKey,
    required this.restartKey,
  });

  AppKeys copyWith({
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
    GlobalKey<NavigatorState>? navigatorKey,
    GlobalKey? restartKey,
  }) {
    return AppKeys(
      scaffoldMessengerKey: scaffoldMessengerKey ?? this.scaffoldMessengerKey,
      navigatorKey: navigatorKey ?? this.navigatorKey,
      restartKey: restartKey ?? this.restartKey,
    );
  }
}
