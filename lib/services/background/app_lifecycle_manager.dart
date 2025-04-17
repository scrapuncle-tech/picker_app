import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      BackgroundFetch.start()
          .then((int status) {
            debugPrint('[BackgroundFetch] start success: $status');
          })
          .catchError((e) {
            debugPrint('[BackgroundFetch] start FAILURE: $e');
          });
    } else if (state == AppLifecycleState.resumed) {
      BackgroundFetch.stop().then((int status) {
        debugPrint('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
