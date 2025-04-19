import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../models/logger.entity.dart'; // Changed import to use your new Logger entity
import '../../providers/app_keys.provider.dart';

enum SnackBarType { error, success, casual }

class CustomSnackBar {
  static void listen({required WidgetRef ref}) {
    objectbox!.loggerBox.query().watch(triggerImmediately: true).listen((
      query,
    ) {
      final logs = query.find();
      if (logs.isEmpty) return;

      final latest = logs.last;

      // Only proceed if message is not null AND not already processed
      if (latest.message != null &&
          latest.message!.isNotEmpty &&
          latest.status != null) {
        // Store message locally
        final message = latest.message!;
        final logStatus = latest.status!;

        // Delete the log entry after reading it
        objectbox!.loggerBox.remove(latest.id);

        // Show the snackbar
        show(ref: ref, message: message, type: logStatus);
      }
    });
  }

  // Renamed method that logs messages with appropriate status
  static void log({required SnackBarType status, required String message}) {
    try {
      // Create and save a new Logger entry
      final logger = Logger(status: status, message: message);

      objectbox!.loggerBox.put(logger);
    } catch (e) {
      debugPrint("Failed to log message to ObjectBox: $e");
    }
  }

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

    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Center(
        child: Text(
          message,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        ),
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );

    final state = scaffoldMessengerKey.currentState;
    if (state != null) {
      // Immediately hide the current snackbar
      state.hideCurrentSnackBar();

      // Short delay ensures current snackbar is cleared before showing the new one
      Future.delayed(const Duration(milliseconds: 50), () {
        state.showSnackBar(snackBar);
      });
    }
  }
}
