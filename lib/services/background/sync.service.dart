import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../objectbox/auth.service.dart';
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
        _startSync();
      } else {
        _stopSync();
      }
    });
  }

  void _startSync() {
    debugPrint('Starting sync...');
    OBAuthService obAuthService = OBAuthService(objectbox: objectbox);
    OBRouteService obRouteService = OBRouteService(objectbox: objectbox);
    OBProductService productService = OBProductService(objectbox: objectbox);

    obAuthService.syncPicker();
    obRouteService.syncRoute();
    obRouteService.syncCompletedPickup();
    productService.syncProducts();
  }

  void _stopSync() {
    debugPrint('Stopping sync...');
    OBAuthService obAuthService = OBAuthService(objectbox: objectbox);
    OBRouteService obRouteService = OBRouteService(objectbox: objectbox);
    OBProductService productService = OBProductService(objectbox: objectbox);

    obAuthService.dispose();
    obRouteService.dispose();
    productService.dispose();
  }

  void clearBox() {
    debugPrint('Clearing all boxes...');
    _connectivitySubscription?.cancel();
    objectbox.pickerBox.removeAll();
    objectbox.routeBox.removeAll();
    objectbox.pickupBox.removeAll();
    objectbox.itemBox.removeAll();
    objectbox.productBox.removeAll();
    objectbox.localStatePickupBox.removeAll();
  }
}
