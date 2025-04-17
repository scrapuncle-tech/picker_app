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
    _receivePort!.listen(_handleMessage);

    final isolateData = SyncIsolateData(
      sendPort: _receivePort!.sendPort,
      rootIsolateToken: RootIsolateToken.instance!,
    );

    _isolate = await Isolate.spawn<SyncIsolateData>(
      syncEntryPoint,
      isolateData,
      debugName: "SyncIsolate",
    );
  }

  void _handleMessage(dynamic message) {
    debugPrint("[SYNC LOG]: $message");

    if (message == 'start_sync' && objectbox != null) {
      try {
        SyncService(objectbox: objectbox!).monitorConnectivity();
        debugPrint("[SYNC LOG]: Sync initialized from main isolate.");
      } catch (e) {
        debugPrint("[SYNC LOG]: Sync error in main isolate: $e");
      }
    }
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
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    data.sendPort.send('start_sync');
  } catch (e) {
    data.sendPort.send('Sync isolate error: $e');
  }
}
