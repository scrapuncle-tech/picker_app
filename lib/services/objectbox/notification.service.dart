import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/notification.entity.dart';
import '../../models/objectbox_output/objectbox.g.dart';
import '../firebase/write.service.dart';
import 'object_box.dart';

class OBNotificationService {
  final ObjectBox objectbox;
  final WriteService _writeService = WriteService();
  StreamSubscription? _notificationSubscription;
  final Function? onSynced;

  OBNotificationService({required this.objectbox, this.onSynced});

  /// Syncs all pending notifications to Firebase
  /// Private implementation
  Future<void> _syncPendingNotifications() async {
    _notificationSubscription = objectbox.notificationBox
        .query(NotificationEntity_.isSynced.equals(false))
        .watch(triggerImmediately: true)
        .listen((query) async {
          final pendingNotifications = query.find();

          if (pendingNotifications.isEmpty) {
            debugPrint('No pending notifications to sync');
            return;
          }

          debugPrint(
            'Syncing ${pendingNotifications.length} pending notifications',
          );

          for (var notification in pendingNotifications) {
            final success = await _writeService.putNotification(
              notification: notification,
            );
            if (success) {
              // Remove notification from local database after successful sync to Firebase
              objectbox.notificationBox.remove(notification.obxId);
              debugPrint(
                'Successfully synced and removed notification: ${notification.id}',
              );
            } else {
              debugPrint('Failed to sync notification: ${notification.id}');
            }
          }

          if (onSynced != null) {
            onSynced!();
          }
        });
  }

  /// Creates a notification when subStatus is modified
  NotificationEntity createSubStatusNotification({
    required String pickupId,
    required String previousStatus,
    required String newStatus,
    required String pickerName,
    required String targetSupervisor,
  }) {
    final notification = NotificationEntity(
      id: const Uuid().v4(),
      title: 'Pickup Status Updated',
      message:
          'Pickup $pickupId status changed from $previousStatus to $newStatus',
      details: [
        'Picker $pickerName has updated the status of pickup $pickupId from $previousStatus to $newStatus',
        'Status change time: ${DateTime.now().toString()}',
        'Previous status: $previousStatus',
        'New status: $newStatus',
      ],
      targetSupervisor: targetSupervisor,
      timestamp: DateTime.now(),
      isSynced: false,
    );

    objectbox.notificationBox.put(notification);
    return notification;
  }

  /// Creates a notification for Exotel API error
  NotificationEntity createExotelErrorNotification({
    required String pickupId,
    required String errorMessage,
    required String pickerName,
    required String targetSupervisor,
  }) {
    final notification = NotificationEntity(
      id: const Uuid().v4(),
      title: 'Exotel API Error',
      message: 'Error calling customer for pickup $pickupId',
      details: [
        'Picker $pickerName encountered an error while calling customer for pickup $pickupId: $errorMessage',
        'Error time: ${DateTime.now().toString()}',
        'Error details: $errorMessage',
      ],
      targetSupervisor: targetSupervisor,
      timestamp: DateTime.now(),
      isSynced: false,
    );

    objectbox.notificationBox.put(notification);
    return notification;
  }

  /// Public method to sync notifications
  /// Called from SyncService
  Future<void> syncNotifications() async {
    return _syncPendingNotifications();
  }

  void dispose() {
    _notificationSubscription?.cancel();
  }
}
