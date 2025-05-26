import 'package:objectbox/objectbox.dart';

@Entity()
class NotificationEntity {
  @Id()
  int obxId;

  @Unique(onConflict: ConflictStrategy.replace)
  String id;

  String details;
  String? imageUrl;
  bool isRead;  
  String message;
  String targetSupervisor;
  String? targetScreen;
  
  @Property(type: PropertyType.dateNano)
  DateTime timestamp;
  
  String title;
  
  // Flag to track if notification has been synced to Firebase
  bool isSynced;

  NotificationEntity({
    this.obxId = 0,
    required this.id,
    required this.details,
    this.imageUrl,
    this.isRead = false,
    required this.message,
    required this.targetSupervisor,
    this.targetScreen,
    required this.timestamp,
    required this.title,
    this.isSynced = false,
  });

  NotificationEntity copyWith({
    int? obxId,
    String? id,
    String? details,
    String? imageUrl,
    bool? isRead,
    String? message,
    String? targetSupervisor,
    String? targetScreen,
    DateTime? timestamp,
    String? title,
    bool? isSynced,
  }) {
    return NotificationEntity(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      details: details ?? this.details,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      message: message ?? this.message,
      targetSupervisor: targetSupervisor ?? this.targetSupervisor,
      targetScreen: targetScreen ?? this.targetScreen,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  static NotificationEntity fromFirebase(Map<String, dynamic> data) {
    return NotificationEntity(
      id: data['id'] ?? '',
      details: data['details'] ?? '',
      imageUrl: data['imageUrl'],
      isRead: data['isRead'] ?? false,
      message: data['message'] ?? '',
      targetSupervisor: data['targetSupervisor'] ?? '',
      targetScreen: data['targetScreen'],
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      title: data['title'] ?? '',
      isSynced: true,
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'details': details,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'message': message,
      'targetSupervisor': targetSupervisor,
      'targetScreen': targetScreen,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
    };
  }

  static NotificationEntity createEmptyNotification() {
    return NotificationEntity(
      id: '',
      details: '',
      imageUrl: null,
      isRead: false,
      message: '',
      targetSupervisor: '',
      targetScreen: null,
      timestamp: DateTime.now(),
      title: '',
    );
  }

  @override
  String toString() {
    return 'NotificationEntity('
        'obxId: $obxId, '
        'id: $id, '
        'title: $title, '
        'message: $message, '
        'targetSupervisor: $targetSupervisor, '
        'isRead: $isRead, '
        'isSynced: $isSynced'
        ')';
  }
}
