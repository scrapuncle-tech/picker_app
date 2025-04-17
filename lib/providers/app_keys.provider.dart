import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../models/app_keys.model.dart';

class AppKeysNotifier extends StateNotifier<AppKeys> {
  AppKeysNotifier()
      : super(AppKeys(
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
          navigatorKey: GlobalKey<NavigatorState>(),
          restartKey: GlobalKey(),
        ));

  void restartApp() {
    state = state.copyWith(restartKey: GlobalKey());
  }

  void updateNavigatorKey(GlobalKey<NavigatorState> newKey) {
    state = state.copyWith(navigatorKey: newKey);
  }

  void updateScaffoldMessengerKey(GlobalKey<ScaffoldMessengerState> newKey) {
    state = state.copyWith(scaffoldMessengerKey: newKey);
  }
}

final appKeysProvider =
    StateNotifierProvider<AppKeysNotifier, AppKeys>((ref) => AppKeysNotifier());
