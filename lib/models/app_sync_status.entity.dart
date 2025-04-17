import 'package:objectbox/objectbox.dart';

@Entity()
class SyncStatus {
  int id;
  final bool isSyncing;
  final bool isSynced;

  @Property(type: PropertyType.dateNano)
  final DateTime lastSyncTime;

  SyncStatus({
    this.id = 0,
    required this.isSyncing,
    required this.isSynced,
    required this.lastSyncTime,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    bool? isSynced,
    DateTime? lastSyncTime,
  }) {
    return SyncStatus(
      id: id,
      isSyncing: isSyncing ?? this.isSyncing,
      isSynced: isSynced ?? this.isSynced,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}
