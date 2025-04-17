import 'package:flutter/material.dart';

// import 'worker_manager.service.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  // final WMService wmService = WMService();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // wmService.registerWorkmanagerTask(); // App going to background
    } else if (state == AppLifecycleState.resumed) {
      // wmService.cancelWorkmanagerTask(); // App back to foreground
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
