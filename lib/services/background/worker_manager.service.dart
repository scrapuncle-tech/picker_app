// import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';

// import '../../main.dart';
// import 'sync.service.dart';

// const String backgroundSyncTask = 'background_sync_task';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     // Ensure Flutter bindings are initialized
//     WidgetsFlutterBinding.ensureInitialized();

//     // Add your sync logic here
//     switch (taskName) {
//       case backgroundSyncTask:

//         // Utilizing the ObjectBox instance from the main.dart
//         SyncService(
//           objectbox: objectbox,
//         ).startSync(); // your Firebase ↔ ObjectBox logic
//         break;
//     }

//     return Future.value(true); // Must return true when done
//   });
// }

// class WMService {
//   void registerWorkmanagerTask() {
//     Workmanager().registerPeriodicTask(
//       backgroundSyncTask,
//       backgroundSyncTask,
//       frequency: const Duration(minutes: 15),
//       initialDelay: const Duration(minutes: 1),
//       existingWorkPolicy: ExistingWorkPolicy.keep,
//       constraints: Constraints(networkType: NetworkType.connected),
//     );
//   }

//   Future<void> cancelWorkmanagerTask() async {
//     await Workmanager().cancelByUniqueName(backgroundSyncTask);
//   }
// }
