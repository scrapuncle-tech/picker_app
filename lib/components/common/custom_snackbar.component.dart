import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_keys.provider.dart';

// Enum for different types of snack bars
enum SnackBarType { error, success, casual }

class CustomSnackBar {
  static void show({
    required WidgetRef ref,
    required String message,
    required SnackBarType type,
  }) {
    debugPrint(message);
    final scaffoldMessengerKey = ref.read(appKeysProvider).scaffoldMessengerKey;
    final Color backgroundColor;
    final Color textColor;

    switch (type) {
      case SnackBarType.error:
        backgroundColor = Colors.redAccent;
        textColor = Colors.white;
        break;
      case SnackBarType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case SnackBarType.casual:
        backgroundColor = Colors.blueGrey;
        textColor = Colors.white;
        break;
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Center(
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
