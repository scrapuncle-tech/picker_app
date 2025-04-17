import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/app_sync_status.entity.dart';

class SyncStatusNotifier extends StateNotifier<SyncStatus?> {
  SyncStatusNotifier() : super(null) {
    getSyncStatus();
  }

  void getSyncStatus() {
    objectbox!.syncStatusBox.query().watch(triggerImmediately: true).listen((
      query,
    ) {
      SyncStatus? syncStatus = query.findFirst();
      state = syncStatus;
    });
  }
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus?>(
      (ref) => SyncStatusNotifier(),
    );
