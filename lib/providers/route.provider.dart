import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/pickup.entity.dart';
import '../models/route_info.model.dart';
import '../services/objectbox/route.service.dart';

class RouteInfoNotifier extends StateNotifier<RouteInfo> {
  final OBRouteService _routeService = OBRouteService(objectbox: objectbox!);
  RouteInfoNotifier() : super(RouteInfo.empty()) {
    getRouteData();
    mergeLocalPickupChanges();
  }

  void getRouteData() {
    _routeService.getRoute().listen((route) async {
      if (route == null) {
        state = RouteInfo(
          route: null,
          pickups: [],
          completedPickups: [],
          isLoading: false,
        );
      } else {
        /// get all the uncompleted pickups (may contain localy completed pickups)
        List<Pickup> notCompletedPickups =
            route.pickupsData
                .where((data) => data.isCompleted == false)
                .toList();

        /// get all the completed pickups
        List<Pickup> completedPickups =
            route.pickupsData
                .where((data) => data.isCompleted == true)
                .toList();

        // Sort the pickups by index
        notCompletedPickups.sort(
          (a, b) => a.firebaseIndex.compareTo(b.firebaseIndex),
        );
        completedPickups.sort(
          (a, b) => a.firebaseIndex.compareTo(b.firebaseIndex),
        );

        // State update
        state = RouteInfo(
          route: route,
          pickups: notCompletedPickups,
          completedPickups: completedPickups,
          isLoading: false,
        );
      }
    });
  }

  /// Merge local changes of pickups
  /// and also remove the pickups that are not there in the uncompleted pickups list
  void mergeLocalPickupChanges() async {
    _routeService.getLocalPickups().listen((List<Pickup> localPickups) {
      debugPrint(
        "LOCAL PICKUPS to MERGE : ${localPickups.map((e) => [e.id, e.itemsData]).toList()}",
      );
      if (state.pickups.isNotEmpty) {
        List<Pickup> notCompletedPickups = state.pickups;

        for (Pickup localPickup in localPickups) {
          int index = notCompletedPickups.indexWhere(
            (data) => data.id == localPickup.id,
          );
          if (index != -1) {
            notCompletedPickups[index] = localPickup;
          }
        }

        // Sort the pickups by index
        notCompletedPickups.sort(
          (a, b) => a.firebaseIndex.compareTo(b.firebaseIndex),
        );
        // update the local state of pickups
        state = state.copyWith(pickups: notCompletedPickups);
      }
    });
  }
}

final routeInfoProvider = StateNotifierProvider<RouteInfoNotifier, RouteInfo>(
  (ref) => RouteInfoNotifier(),
);
