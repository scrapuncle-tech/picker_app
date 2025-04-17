import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/item.entity.dart';
import '../models/pickup.entity.dart';
import '../services/objectbox/route.service.dart';

/// Provides the current pickup and whether it is local or from db.
class CurrentPickupNotifier extends StateNotifier<(Pickup?, bool)> {
  final OBRouteService _routeService = OBRouteService(objectbox: objectbox!);

  CurrentPickupNotifier() : super((null, false));

  void init({required Pickup pickup, required bool isLocal}) {
    state = (_calculateTotalPrice(pickup), isLocal);
  }

  void close() {
    final pickup = state.$1;
    if (pickup != null) {
      _routeService.updatePickup(pickup: pickup);
    }
    // Don't clear state here to avoid widget errors on dispose
  }

  void addItem({required Item item}) {
    final pickup = state.$1;
    if (pickup == null) return;

    final updatedItems = [...pickup.itemsData, item];
    final updatedPickup = pickup.copyWith(itemsData: updatedItems);

    state = (_calculateTotalPrice(updatedPickup), state.$2);
  }

  void removeItem({required Item item}) {
    final pickup = state.$1;
    if (pickup == null) return;

    final updatedItems =
        pickup.itemsData.where((i) => i.id != item.id).toList();
    final updatedPickup = pickup.copyWith(itemsData: updatedItems);

    state = (_calculateTotalPrice(updatedPickup), state.$2);
  }

  Pickup? _calculateTotalPrice(Pickup? pickup) {
    if (pickup == null) return null;

    double total = 0;
    for (final item in pickup.itemsData) {
      total += item.totalPrice;
    }

    return pickup.copyWith(totalPrice: total);
  }

  void setCompleted() {
    final pickup = state.$1;
    if (pickup == null) return;

    final updatedPickup = pickup.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      status: 'completed',
    );

    state = (updatedPickup, state.$2);
    _routeService.updatePickup(pickup: updatedPickup);
  }
}

final currentPickupProvider =
    StateNotifierProvider<CurrentPickupNotifier, (Pickup?, bool)>(
      (ref) => CurrentPickupNotifier(),
    );
