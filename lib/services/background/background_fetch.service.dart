import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';

import '../firebase/firebase_options.dart';
import '../objectbox/object_box.dart';
import 'sync.service.dart';

const String backgroundSyncTask = 'background_sync_task';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    debugPrint("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  debugPrint('[BackgroundFetch] Headless event received.');

  ObjectBox? obx;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    obx = await ObjectBox.create(); // Only safe if app is terminated
    SyncService(objectbox: obx).monitorConnectivity();
  } catch (e) {
    debugPrint("Failed to initialize ObjectBox and Firebase in background: $e");
  } finally {
    obx?.store.close(); // Always close store to prevent leak
    BackgroundFetch.finish(taskId);
  }
}

class BackgroundFetchService {
  static Future<void> configureBackgroundFetch() async {
    final status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        // <-- Event handler
        // This is the fetch-event callback.
        debugPrint("[BackgroundFetch] Event received $taskId");
        // IMPORTANT:  You must signal completion of your task or the OS can punish your app
        // for taking too long in the background.
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        // <-- Task timeout handler.
        // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
        debugPrint("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
        BackgroundFetch.finish(taskId);
      },
    );
    debugPrint("[BackgroundFetch] configure $status");
  }
}
