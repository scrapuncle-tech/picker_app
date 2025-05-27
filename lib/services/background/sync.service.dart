import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../models/app_sync_status.entity.dart';
import '../objectbox/auth.service.dart';
import '../objectbox/notification.service.dart';
import '../objectbox/object_box.dart';
import '../objectbox/product.service.dart';
import '../objectbox/route.service.dart';

class SyncService {
  ObjectBox objectbox;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  SyncService({required this.objectbox});

  void monitorConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.ethernet)) {
        debugPrint('Internet connection restored. Triggering sync...');
        updateSyncStatus(isSyncing: true);
        startSync();
      } else {
        debugPrint('Internet connection lost. Stopping sync...');
        stopSync();
      }
    });
  }

  void updateSyncStatus({bool isSyncing = false}) {
    final existingStatus =
        objectbox.syncStatusBox.query().build().findFirst() ??
        SyncStatus(
          isSyncing: false,
          isSynced: false,
          lastSyncTime: DateTime.now(),
        );

    final updated = existingStatus.copyWith(
      isSyncing: isSyncing,
      isSynced: !isSyncing,
      lastSyncTime: DateTime.now(),
    );

    objectbox.syncStatusBox.put(updated);
  }

  void startSync() {
    debugPrint('Starting sync...');

    void updateStatus() => updateSyncStatus(isSyncing: false);

    OBAuthService obAuthService = OBAuthService(
      objectbox: objectbox,
      onSynced: updateStatus,
    );
    OBRouteService obRouteService = OBRouteService(
      objectbox: objectbox,
      onSynced: updateStatus,
    );
    OBProductService productService = OBProductService(
      objectbox: objectbox,
      onSynced: updateStatus,
    );

    OBNotificationService notificationService = OBNotificationService(
      objectbox: objectbox,
      onSynced: updateStatus,
    );

    obAuthService.syncPicker();
    obRouteService.syncRoute();
    obRouteService.syncLocalPickup();
    productService.syncProducts();
    notificationService.syncNotifications();
  }

  void stopSync() {
    debugPrint('Stopping sync...');
    OBAuthService obAuthService = OBAuthService(objectbox: objectbox);
    OBRouteService obRouteService = OBRouteService(objectbox: objectbox);
    OBProductService productService = OBProductService(objectbox: objectbox);
    OBNotificationService notificationService = OBNotificationService(
      objectbox: objectbox,
    );

    obAuthService.dispose();
    obRouteService.dispose();
    productService.dispose();
    notificationService.dispose();
  }

  void clearBox() {
    debugPrint('Clearing all boxes...');
    _connectivitySubscription?.cancel();
    objectbox.pickerBox.removeAll();
    objectbox.routeBox.removeAll();
    objectbox.pickupBox.removeAll();
    // objectbox.itemBox.removeAll();
    objectbox.productBox.removeAll();
    // objectbox.localStatePickupBox.removeAll();
    // objectbox.notificationBox.removeAll();
  }
}
