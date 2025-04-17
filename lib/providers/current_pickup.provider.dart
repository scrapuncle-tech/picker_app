import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/item.entity.dart';
import '../models/pickup.entity.dart';
import '../services/objectbox/route.service.dart';

/// provides the current pickup and wheather it is local or from db

class CurrentPickupNotifier extends StateNotifier<(Pickup?, bool)> {
  final OBRouteService _routeService = OBRouteService(objectbox: objectbox!);

  CurrentPickupNotifier() : super((null, false));

  void init({required Pickup pickup, required bool isLocal}) {
    state = (pickup, isLocal);
  }

  void close() {
    if (state.$1 != null) {
      _routeService.updatePickup(pickup: state.$1!);
    }
    state = (null, false);
  }

  void addItem({required Item item}) {
    final updatedPickup = state.$1?.copyWith();
    updatedPickup?.itemsData.add(item);
    state = (_calculateTotalPrice(updatedPickup), state.$2);
  }

  void removeItem({required Item item}) {
    final updatedPickup = state.$1?.copyWith();
    updatedPickup?.itemsData.remove(item);
    state = (_calculateTotalPrice(updatedPickup), state.$2);
  }

  Pickup? _calculateTotalPrice(Pickup? pickup) {
    double totalPrice = 0;
    for (final item in pickup?.itemsData ?? []) {
      totalPrice += item.customPrice ?? double.parse(item.product.price);
    }
    return pickup?.copyWith(totalPrice: totalPrice);
  }

  void setCompleted() {
    if (state.$1 != null) {
      state = (
        state.$1?.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          status: 'completed',
        ),
        state.$2,
      );

      _routeService.updatePickup(pickup: state.$1!);
    }

    state = (null, false);
  }
}

final currentPickupProvider =
    StateNotifierProvider<CurrentPickupNotifier, (Pickup?, bool)>(
      (ref) => CurrentPickupNotifier(),
    );
