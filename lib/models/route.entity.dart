import 'package:objectbox/objectbox.dart';

import 'pickup.entity.dart';

@Entity()
class RouteModel {
  @Id()
  int obxId;
  @Unique(onConflict: ConflictStrategy.replace)
  String id;
  //

  String name;
  String mapLink;

  /// Reference to asset checks
  String morningAssetCheck;
  String eveningAssetCheck;

  String pickerFirebaseId;
  String helperId;
  List<String> pickupIds;

  /// Reference to pickups
  @Backlink('routeModel')
  final pickupsData = ToMany<Pickup>();

  @Property(type: PropertyType.date)
  DateTime scheduledDate;
  @Property(type: PropertyType.dateNano)
  DateTime updatedAt;

  RouteModel({
    this.obxId = 0,
    required this.id,
    required this.name,
    required this.morningAssetCheck,
    required this.eveningAssetCheck,
    required this.pickerFirebaseId,
    required this.helperId,
    required this.pickupIds,
    required this.mapLink,
    required this.scheduledDate,
    required this.updatedAt,
  });

  RouteModel copyWith({
    int? obxId,
    String? id,
    String? name,
    String? mapLink,
    String? morningAssetCheck,
    String? eveningAssetCheck,
    String? pickerFirebaseId,
    String? helperId,
    List<String>? pickupIds,
    List<Pickup>? pickups,
    DateTime? scheduledDate,
    DateTime? updatedAt,
  }) {
    RouteModel route = RouteModel(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      name: name ?? this.name,
      morningAssetCheck: morningAssetCheck ?? this.morningAssetCheck,
      eveningAssetCheck: eveningAssetCheck ?? this.eveningAssetCheck,
      pickerFirebaseId: pickerFirebaseId ?? this.pickerFirebaseId,
      pickupIds: pickupIds ?? this.pickupIds,
      helperId: helperId ?? this.helperId,
      mapLink: mapLink ?? this.mapLink,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    if (pickups != null) {
      route.pickupsData.addAll(pickups);
    } else {
      route.pickupsData.addAll(pickupsData);
    }

    return route;
  }

  factory RouteModel.fromFirebase(Map<String, dynamic> data) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }

    RouteModel route = RouteModel(
      id: data['id'],
      name: data['name'] ?? '',
      mapLink: data['mapLink'] ?? '',
      morningAssetCheck: data['morningAssetCheck'] ?? '',
      eveningAssetCheck: data['eveningAssetCheck'] ?? '',
      pickerFirebaseId: data['picker'] ?? '',
      pickupIds: List<String>.from(data['pickups'] ?? []),
      helperId: data['helper'] ?? '',
      scheduledDate: parseDate(data['scheduledDate']) ?? DateTime.now(),
      updatedAt: parseDate(data['updatedAt']) ?? DateTime.now(),
    );

    return route;
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'mapLink': mapLink,
      'morningAssetCheck': morningAssetCheck,
      'eveningAssetCheck': eveningAssetCheck,
      'picker': pickerFirebaseId,
      'pickups': pickupIds,
      'helper': helperId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RouteModel('
        'obxId: $obxId, '
        'id: $id, '
        'name: $name, '
        'pickups: ${pickupsData.map((p) => p.id).toList()}'
        ')';
    // 'mapLink: $mapLink, '
    // 'morningAssetCheck: $morningAssetCheck, '
    // 'eveningAssetCheck: $eveningAssetCheck, '
    // 'pickerFirebaseId: $pickerFirebaseId, '
    // 'helperId: $helperId, '
    // 'pickupIds: $pickupIds, '
    // 'scheduledDate: $scheduledDate, '
    // 'updatedAt: $updatedAt, '
    // 'pickups: ${pickups.map((p) => p.id).toList()}'
    // ')';
  }
}
