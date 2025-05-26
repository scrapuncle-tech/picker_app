import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/item.entity.dart';
import '../models/pickup.entity.dart';
import '../services/objectbox/notification.service.dart';
import '../services/objectbox/route.service.dart';
import 'route.provider.dart';

/// Provides the current pickup and whether it is local or from db.
class CurrentPickupNotifier extends StateNotifier<(Pickup?, bool)> {
  final Ref ref;
  final OBRouteService _routeService = OBRouteService(objectbox: objectbox!);
  final OBNotificationService _notificationService = OBNotificationService(
    objectbox: objectbox!,
  );

  CurrentPickupNotifier(this.ref) : super((null, false));

  void init({required Pickup pickup, required bool isLocal}) {
    state = (_calculateTotalPrice(pickup), isLocal);
  }

  void close() {
    final pickup = state.$1;
    if (pickup != null) {
      _updateTime(pickup.copyWith(isUpdated: true));
    }
    // Don't clear state here to avoid widget errors on dispose
  }

  void updateSubStatus({required String subStatus}) {
    final pickup = state.$1;
    if (pickup == null) return;

    final supervisorId = ref.read(routeInfoProvider).route?.morningSupervisor;

    // Store the previous status for notification
    final previousStatus = pickup.subStatus;
    final updatedPickup = pickup.copyWith(subStatus: subStatus);

    // Create notification for status change
    if (previousStatus != subStatus) {
      _notificationService.createSubStatusNotification(
        pickupId: pickup.pickupId,
        previousStatus: previousStatus.isEmpty ? 'None' : previousStatus,
        newStatus: subStatus,
        pickerName: pickup.pickerId,
        targetSupervisor: supervisorId ?? "none",
      );
    }

    _updateTime(updatedPickup);
  }

  void addItem({required Item item}) {
    final pickup = state.$1;
    if (pickup == null) return;

    final updatedItems = [...pickup.itemsData, item];
    final updatedPickup = pickup.copyWith(itemsData: updatedItems);
    _updateTime(updatedPickup);
  }

  void removeItem({required Item item}) {
    final pickup = state.$1;
    if (pickup == null) return;
    final updatedItems =
        pickup.itemsData.where((i) => i.id != item.id).toList();
    final updatedPickup = pickup.copyWith(itemsData: updatedItems);

    _updateTime(updatedPickup);
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
      updatedAt: DateTime.now(),
      status: 'completed',
    );

    _updateTime(updatedPickup);
  }

  void _updateTime(Pickup pickup) {
    final updatedPickup = pickup.copyWith(updatedAt: DateTime.now());
    final updatedPickupWithTotalPrice = _calculateTotalPrice(updatedPickup);
    if (updatedPickupWithTotalPrice != null) {
      state = (updatedPickupWithTotalPrice, state.$2);
      _routeService.updatePickup(pickup: updatedPickupWithTotalPrice);
    }
  }

  void updatePickup(Pickup pickup) {
    _routeService.updatePickup(pickup: pickup);
  }
}

final currentPickupProvider =
    StateNotifierProvider<CurrentPickupNotifier, (Pickup?, bool)>(
      (ref) => CurrentPickupNotifier(ref),
    );
