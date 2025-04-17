import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../main.dart';
import 'sync.service.dart';
import '../firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class AppStateSync {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  Future<void> startSync() async {
    if (_isolate != null) return;

    _receivePort = ReceivePort();

    final isolateData = SyncIsolateData(
      sendPort: _receivePort!.sendPort,
      rootIsolateToken: RootIsolateToken.instance!,
    );

    _isolate = await Isolate.spawn<SyncIsolateData>(
      syncEntryPoint,
      isolateData,
      debugName: "SyncIsolate",
    );

    _receivePort!.listen((message) async {
      debugPrint("[SYNC LOG]: $message");

      // Handle sync request in the main isolate
      if (message == 'start_sync') {
        if (objectbox == null) {
          debugPrint("[SYNC LOG]: ObjectBox not initialized in main isolate.");
          return;
        }

        try {
          SyncService(objectbox: objectbox!).monitorConnectivity();
          debugPrint("[SYNC LOG]: Main isolate sync completed.");
        } catch (e) {
          debugPrint("[SYNC LOG]: Main isolate sync error: $e");
        }
      }
    });
  }

  void stopSync() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    _receivePort?.close();
    _receivePort = null;
  }
}

class SyncIsolateData {
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  SyncIsolateData({required this.sendPort, required this.rootIsolateToken});
}

Future<void> syncEntryPoint(SyncIsolateData data) async {
  // Ensure platform channels are initialized for background isolate
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);

  final send = data.sendPort;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Simulate background logic, then send sync trigger
    send.send('start_sync');
  } catch (e) {
    send.send('Sync isolate error: $e');
  }
}
