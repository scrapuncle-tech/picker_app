import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/objectbox_output/objectbox.g.dart';
import '../../models/pickup.entity.dart';
import '../../models/route.entity.dart';
import '../firebase/read.service.dart';
import '../firebase/write.service.dart';
import 'auth.service.dart';
import 'object_box.dart';

class OBRouteService {
  final ObjectBox objectbox;
  OBRouteService({required this.objectbox});

  final Set<String> _activeRouteListeners = {};
  final Set<String> _activePickupListeners = {};
  final List<StreamSubscription> _subscriptions = [];

  StreamSubscription? _pickerSubscription;

  void syncRoute() {
    _pickerSubscription?.cancel();

    _pickerSubscription = OBAuthService(
      objectbox: objectbox,
    ).getPicker().listen((picker) {
      if (picker == null) return;

      if (_activeRouteListeners.contains(picker.id)) return;
      _activeRouteListeners.add(picker.id);

      final routeSubscription = ReadService().getRoute(pickerId: picker.id).listen((
        route,
      ) {
        if (route != null) {
          final existingRoute =
              objectbox.routeBox
                  .query(RouteModel_.id.equals(route.id))
                  .build()
                  .findFirst();

          RouteModel updatedRoute =
              existingRoute != null
                  ? route.copyWith(obxId: existingRoute.obxId)
                  : route;

          debugPrint(
            "Updated route => ${updatedRoute.id} when any route data is changed and all the pickups linked to it will be replaced by the new ones",
          );

          List<Pickup> newPickups = [];
          int totalPickups = route.pickupIds.length;
          int fetchedCount = 0;

          if (totalPickups == 0) {
            _replaceRouteWithPickups(updatedRoute, []);
            debugPrint("No pickups in route => ${updatedRoute.id}");
            return;
          }

          for (final pickupId in route.pickupIds) {
            if (_activePickupListeners.contains(pickupId)) continue;
            _activePickupListeners.add(pickupId);

            final pickupSubscription = ReadService()
                .getPickup(id: pickupId)
                .listen((pickup) {
                  final existingPickup =
                      objectbox.pickupBox
                          .query(Pickup_.id.equals(pickup.id))
                          .build()
                          .findFirst();

                  if (existingPickup != null) {
                    debugPrint("Found an existing pickup => $pickupId");
                    pickup = pickup.copyWith(
                      firebaseIndex: route.pickupIds.indexOf(pickupId),
                      obxId: existingPickup.obxId,
                    );
                  } else {
                    debugPrint("Added a new pickup => $pickupId");
                    pickup = pickup.copyWith(
                      firebaseIndex: route.pickupIds.indexOf(pickupId),
                    );
                  }

                  objectbox.pickupBox.put(pickup);
                  newPickups.add(pickup);

                  fetchedCount++;
                  if (fetchedCount >= totalPickups) {
                    _replaceRouteWithPickups(updatedRoute, newPickups);

                    debugPrint(
                      "Final Updated route => ${updatedRoute.id} and OBXID: ${updatedRoute.obxId} with pickups => ${updatedRoute.pickupsData.map((p) => p.id).toList()}",
                    );
                  }
                });

            _subscriptions.add(pickupSubscription);
          }
        }
      });

      _subscriptions.add(routeSubscription);
    });

    _subscriptions.add(_pickerSubscription!);
  }

  void _replaceRouteWithPickups(
    RouteModel updatedRoute,
    List<Pickup> newPickups,
  ) {
    final existing =
        objectbox.routeBox
            .query(RouteModel_.id.equals(updatedRoute.id))
            .build()
            .findFirst();

    if (existing != null) {
      existing.pickupsData.clear();
      objectbox.routeBox.put(existing); // Save the cleared relation
    }

    final finalRoute = updatedRoute.copyWith(
      obxId: existing?.obxId,
      pickups: newPickups,
    );

    objectbox.routeBox.put(finalRoute);
  }

  Stream<RouteModel?> getRoute() {
    return objectbox.routeBox.query().watch(triggerImmediately: true).map((
      query,
    ) {
      final list = query.find();
      print(list);
      return list.isNotEmpty ? list.last : null;
    });
  }

  void updatePickup({required Pickup pickup}) {
    final existing =
        objectbox.localStatePickupBox
            .query(Pickup_.id.equals(pickup.id))
            .build()
            .findFirst();

    if (existing == null || !_pickupsEqual(existing, pickup)) {
      objectbox.localStatePickupBox.put(pickup);
    }
  }

  void syncCompletedPickup() {
    final subscription = objectbox.localStatePickupBox
        .query(Pickup_.isCompleted.equals(true))
        .watch(triggerImmediately: true)
        .listen((query) async {
          for (final pickup in query.find()) {
            await WriteService().putPickup(pickup: pickup);
            objectbox.localStatePickupBox.remove(pickup.obxId);
          }
        });

    _subscriptions.add(subscription);
  }

  Stream<List<Pickup>> getLocalPickups() {
    return objectbox.localStatePickupBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  void removeInvalidLocalPickups({required List<Pickup> pickups}) {
    final idsToRemove = pickups.map((p) => p.obxId).toList();
    objectbox.localStatePickupBox.removeMany(idsToRemove);
  }

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _activePickupListeners.clear();
    _activeRouteListeners.clear();
    _pickerSubscription?.cancel();
    _pickerSubscription = null;
  }

  bool _pickupsEqual(Pickup a, Pickup b) {
    return a.id == b.id;
  }
}
