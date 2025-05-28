import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/local_pickup.entity.dart';
import '../../models/objectbox_output/objectbox.g.dart';
import '../../models/pickup.entity.dart';
import '../../models/route.entity.dart';
import '../firebase/read.service.dart';
import '../firebase/write.service.dart';
import 'auth.service.dart';
import 'object_box.dart';

class OBRouteService {
  final ObjectBox objectbox;
  final VoidCallback? onSynced;
  OBRouteService({required this.objectbox, this.onSynced});

  final Set<String> _activeRouteListeners = {};
  final Set<String> _activePickupListeners = {};
  final List<StreamSubscription> _subscriptions = [];
  bool _isSyncingLocalPickups = false;

  StreamSubscription? _pickerSubscription;

  void syncRoute() {
    _pickerSubscription?.cancel();

    _pickerSubscription = OBAuthService(
      objectbox: objectbox,
    ).getPicker().listen((picker) {
      onSynced?.call();
      if (picker == null || _activeRouteListeners.contains(picker.id)) return;

      _activeRouteListeners.add(picker.id);

      final routeSubscription = ReadService().getRoute(pickerId: picker.id).listen((
        route,
      ) async {
        onSynced?.call();

        objectbox.routeBox.removeAll();
        objectbox.pickupBox.removeAll();

        if (route == null) {
          return;
        }

        final existingRoute =
            objectbox.routeBox
                .query(RouteModel_.id.equals(route.id))
                .build()
                .findFirst();

        final updatedRoute =
            existingRoute != null
                ? route.copyWith(obxId: existingRoute.obxId)
                : route;

        debugPrint("Syncing route => ${updatedRoute.id}");

        final Set<String> latestPickupIds = updatedRoute.pickupIds.toSet();
        debugPrint("Pikup IDS : $latestPickupIds");

        // Get existing pickups for this route
        final existingPickupsInRoute =
            existingRoute?.pickupsData.toList() ?? [];
        final obsoletePickups =
            existingPickupsInRoute
                .where((pickup) => !latestPickupIds.contains(pickup.pickupId))
                .toList();

        // Remove obsolete pickups from box and relation
        if (obsoletePickups.isNotEmpty) {
          debugPrint(
            "Removing obsolete pickups: ${obsoletePickups.map((p) => p.pickupId).toList()}",
          );

          // Remove from pickupBox
          objectbox.pickupBox.removeMany(
            obsoletePickups.map((p) => p.obxId).toList(),
          );

          // Also clear from route relation
          existingRoute?.pickupsData.removeWhere(
            (pickup) => obsoletePickups.any((obs) => obs.id == pickup.id),
          );
          if (existingRoute != null) {
            objectbox.routeBox.put(existingRoute);
          }
        }

        // Now sync and attach updated pickups
        Set<Pickup> newPickups = {};

        _replaceRouteWithPickups(updatedRoute, {});

        for (final pickupId in updatedRoute.pickupIds) {
          // Don't skip existing listeners — we might still need to refresh them
          final pickupSubscription = ReadService()
              .getPickup(id: pickupId)
              .listen((pickup) {
                if (pickup != null) {
                  onSynced?.call();
                  final existingPickup =
                      objectbox.pickupBox
                          .query(Pickup_.id.equals(pickup.id))
                          .build()
                          .findFirst();

                  pickup = pickup.copyWith(
                    obxId: existingPickup?.obxId,
                    firebaseIndex: updatedRoute.pickupIds.indexOf(pickupId),
                  );

                  objectbox.pickupBox.put(pickup);
                  newPickups.add(pickup);

                  _replaceRouteWithPickups(updatedRoute, newPickups);
                } else {
                  debugPrint("PICKUP NOT FOUND : pickupId:  $pickupId");
                }
              });

          _subscriptions.add(pickupSubscription);
          _activePickupListeners.add(pickupId); // Add or update
        }
      });

      _subscriptions.add(routeSubscription);
    });

    _subscriptions.add(_pickerSubscription!);
  }

  void _replaceRouteWithPickups(
    RouteModel updatedRoute,
    Set<Pickup> newPickups,
  ) {
    final existing =
        objectbox.routeBox
            .query(RouteModel_.id.equals(updatedRoute.id))
            .build()
            .findFirst();

    if (existing != null) {
      existing.pickupsData.clear(); // Clear old relation
      objectbox.routeBox.put(existing);
    }

    final finalRoute = updatedRoute.copyWith(
      obxId: existing?.obxId,
      pickups: newPickups.toList(),
    );

    objectbox.routeBox.put(finalRoute);

    debugPrint(
      "Updated Route ${finalRoute.id} with pickups: ${newPickups.map((p) => p.pickupId).toList()}",
    );
  }

  Stream<RouteModel?> getRoute() {
    return objectbox.routeBox.query().watch(triggerImmediately: true).map((
      query,
    ) {
      final list = query.find();
      debugPrint(list.toString());
      return list.isNotEmpty ? list.last : null;
    });
  }

  /// Update a pickup in the local state and sync it with Firebase if and only if the pickup is completed.
  void updatePickup({required Pickup pickup}) {
    LocalPickup? existing =
        objectbox.localStatePickupBox
            .query(LocalPickup_.pickupId.equals(pickup.pickupId))
            .build()
            .findFirst();

    final updatedLocalPickup = LocalPickup.fromPickup(
      pickup,
    ).copyWith(obxId: existing?.obxId ?? 0);

    // If existing, preserve relations properly
    if (existing != null) {
      // Replace other fields
      existing = existing.copyWith(
        totalPrice: updatedLocalPickup.totalPrice,
        subStatus: updatedLocalPickup.subStatus,
        itemsData: updatedLocalPickup.itemsData,
        totalWeightQuantity: updatedLocalPickup.totalWeightQuantity,
        status: updatedLocalPickup.status,
        isCompleted: updatedLocalPickup.isCompleted,
        isUpdated: updatedLocalPickup.isUpdated,
        completedAt: updatedLocalPickup.completedAt,
      );

      objectbox.localStatePickupBox.put(existing);
    } else {
      objectbox.localStatePickupBox.put(updatedLocalPickup);
    }

    debugPrint(
      "from UPDATE PICKUP (local): ${pickup.pickupId} "
      "Status: ${pickup.status}==${pickup.isCompleted}",
    );
  }

  void syncLocalPickup() {
    final subscription = objectbox.localStatePickupBox
        .query(
          LocalPickup_.isUpdated
              .equals(true)
              .or(LocalPickup_.isCompleted.equals(true)),
        )
        .watch(triggerImmediately: true)
        .listen((query) async {
          // Prevent re-entry if already syncing
          if (_isSyncingLocalPickups) return;

          _isSyncingLocalPickups = true;
          debugPrint("Trying to sync the local pickups to Firebase");

          final pickupsToSync = query.find();

          for (final pickup in pickupsToSync) {
            bool uploadSuccessful = false;

            /// set the isUpdated flag to false
            objectbox.localStatePickupBox.put(
              pickup.copyWith(isUpdated: false),
            );

            await for (final status in WriteService().putPickup(
              pickup: pickup.toPickup(),
            )) {
              debugPrint("Firebase upload status: $status");

              if (status == 'completed') {
                uploadSuccessful = true;
              } else if (status.startsWith('failed:')) {
                debugPrint("Failed to upload pickup to Firebase: $status");
                break;
              }
            }

            if (uploadSuccessful) {
              debugPrint("Upload successful, removing local pickup data");
              objectbox.localStatePickupBox.remove(pickup.obxId);
            } else {
              debugPrint("Upload failed, keeping local pickup data for retry");
            }
          }

          _isSyncingLocalPickups = false;
        });

    _subscriptions.add(subscription);
  }

  /// Get all the pickups from the local state
  Stream<List<Pickup>> getLocalPickups() {
    return objectbox.localStatePickupBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find().map((e) => e.toPickup()).toList());
  }

  // /// Remove invalid local pickups
  // void removeInvalidLocalPickups({required List<Pickup> localPickups}) {
  //   RouteModel? route = objectbox.routeBox.query().build().findFirst();

  //   if (route != null) {
  //     List<Pickup> notCompletedPickups =
  //         route.pickupsData.where((d) => !d.isCompleted).toList();

  //     List<Pickup> invalidPickups = [];

  //     for (Pickup localPickup in localPickups) {
  //       // if this localPickup is NOT in the route pickups, it’s invalid
  //       bool existsInRoute = notCompletedPickups.any(
  //         (pickup) => pickup.id == localPickup.id,
  //       );
  //       if (!existsInRoute) {
  //         invalidPickups.add(localPickup);
  //       }
  //     }

  //     objectbox.localStatePickupBox.removeMany(
  //       invalidPickups.map((e) => e.obxId).toList(),
  //     );
  //   }
  // }

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
}
