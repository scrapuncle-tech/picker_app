import 'package:objectbox/objectbox.dart';

import 'item.entity.dart';
import 'route.entity.dart';

@Entity()
class Pickup {
  @Id()
  int obxId;

  @Unique(onConflict: ConflictStrategy.replace)
  String id;
  //

  int firebaseIndex;

  String name;
  String mobileNo;
  String address;
  String area;
  String pincode;
  String aov;
  String description;
  String expectedWeight;
  List<String> items;

  /// Relation to items
  @Backlink('pickup')
  final itemsData = ToMany<Item>();
  // Each pickup belongs to a single route
  final routeModel = ToOne<RouteModel>();

  String slot;
  String finalSlot;
  String status;
  String subStatus;
  bool isCompleted;
  bool isLocked;
  String lockedBy;
  String pickerId;
  String pickerPhoneNo;
  String helperId;
  String helperPhoneNo;
  String routeId;
  String mapLink;
  List<String> coordinates;
  double totalPrice;
  double totalWeightQuantity;

  @Property(type: PropertyType.date)
  DateTime createdAt;
  @Property(type: PropertyType.date)
  DateTime date;
  @Property(type: PropertyType.date)
  DateTime finalDate;
  @Property(type: PropertyType.dateNano)
  DateTime? updatedAt;
  @Property(type: PropertyType.dateNano)
  DateTime? completedAt;

  Pickup({
    this.obxId = 0,
    required this.id,
    required this.firebaseIndex,
    required this.name,
    required this.mobileNo,
    required this.address,
    required this.area,
    required this.pincode,
    required this.aov,
    required this.description,
    required this.expectedWeight,
    required this.items,
    required this.slot,
    required this.finalSlot,
    required this.status,
    required this.subStatus,
    required this.isCompleted,
    required this.isLocked,
    required this.lockedBy,
    required this.pickerId,
    required this.pickerPhoneNo,
    required this.helperId,
    required this.helperPhoneNo,
    required this.routeId,
    required this.mapLink,
    required this.createdAt,
    required this.date,
    required this.finalDate,
    required this.updatedAt,
    required this.coordinates,
    this.totalPrice = 0,
    this.totalWeightQuantity = 0,
    this.completedAt,
  });

  Pickup copyWith({
    int? obxId,
    String? id,
    int? firebaseIndex,
    String? name,
    String? mobileNo,
    String? address,
    String? area,
    String? pincode,
    String? aov,
    String? description,
    String? expectedWeight,
    List<String>? items,
    String? slot,
    String? finalSlot,
    String? status,
    String? subStatus,
    bool? isCompleted,
    bool? isLocked,
    String? lockedBy,
    String? pickerId,
    String? pickerPhoneNo,
    String? helperId,
    String? helperPhoneNo,
    String? routeId,
    String? mapLink,
    List<String>? coordinates,
    double? totalPrice,
    double? totalWeightQuantity,
    DateTime? createdAt,
    DateTime? date,
    DateTime? finalDate,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<Item>? itemsData,
  }) {
    Pickup pickup = Pickup(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      firebaseIndex: firebaseIndex ?? this.firebaseIndex,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      address: address ?? this.address,
      area: area ?? this.area,
      pincode: pincode ?? this.pincode,
      aov: aov ?? this.aov,
      description: description ?? this.description,
      expectedWeight: expectedWeight ?? this.expectedWeight,
      items: items ?? this.items,
      slot: slot ?? this.slot,
      finalSlot: finalSlot ?? this.finalSlot,
      status: status ?? this.status,
      subStatus: subStatus ?? this.subStatus,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      lockedBy: lockedBy ?? this.lockedBy,
      pickerId: pickerId ?? this.pickerId,
      pickerPhoneNo: pickerPhoneNo ?? this.pickerPhoneNo,
      helperId: helperId ?? this.helperId,
      helperPhoneNo: helperPhoneNo ?? this.helperPhoneNo,
      routeId: routeId ?? this.routeId,
      mapLink: mapLink ?? this.mapLink,
      coordinates: coordinates ?? this.coordinates,
      totalPrice: totalPrice ?? this.totalPrice,
      totalWeightQuantity: totalWeightQuantity ?? this.totalWeightQuantity,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      finalDate: finalDate ?? this.finalDate,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );

    pickup.itemsData.addAll(itemsData ?? this.itemsData);
    return pickup;
  }

  static Pickup fromFirebase(Map<String, dynamic> data) {
    List<String> coordinates =
        (data['coordinates'] != null &&
                data['coordinates']['latitude'] != null &&
                data['coordinates']['longitude'] != null)
            ? [
              data['coordinates']['latitude'].toString(),
              data['coordinates']['longitude'].toString(),
            ]
            : [];

    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }

    return Pickup(
      id: data['id'] ?? '',
      firebaseIndex:
          data['index'] != null
              ? int.tryParse(data['index'].toString()) ?? 0
              : 0,
      name: data['name'] ?? '',
      mobileNo: data['mobileNo'] ?? '',
      address: data['address'] ?? '',
      area: data['area'] ?? '',
      pincode: data['pincode'] ?? '',
      aov: data['aov'] ?? '',
      description: data['description'] ?? '',
      expectedWeight: data['expectedWeight'] ?? '',
      items: List<String>.from(data['items'] ?? []),
      slot: data['slot'] ?? '',
      finalSlot: data['finalSlot'] ?? '',
      status: data['status'] ?? '',
      subStatus: data['subStatus'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      isLocked: data['isLocked'] ?? false,
      lockedBy: data['lockedBy'] ?? '',
      pickerId: data['pickerId'] ?? '',
      pickerPhoneNo: data['pickerPhoneNo'] ?? '',
      helperId: data['helperId'] ?? '',
      helperPhoneNo: data['helperPhoneNo'] ?? '',
      routeId: data['routeId'] ?? '',
      mapLink: data['mapLink'] ?? '',
      coordinates: coordinates,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      totalWeightQuantity: (data['totalWeightQuantity'] ?? 0).toDouble(),
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
      date: parseDate(data['date']) ?? DateTime.now(),
      finalDate: parseDate(data['finalDate']) ?? DateTime.now(),
      updatedAt: parseDate(data['updatedAt']),
      completedAt: parseDate(data['completedAt']),
    );
  }

  Map<String, dynamic> toFirebase({required List<String> itemIds}) {
    return {
      'id': id,
      'name': name,
      'mobileNo': mobileNo,
      'address': address,
      'area': area,
      'pincode': pincode,
      'aov': aov,
      'description': description,
      'expectedWeight': expectedWeight,
      'items': itemIds,
      'slot': slot,
      'finalSlot': finalSlot,
      'status': status,
      'subStatus': subStatus,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'lockedBy': lockedBy,
      'pickerId': pickerId,
      'pickerPhoneNo': pickerPhoneNo,
      'helperId': helperId,
      'helperPhoneNo': helperPhoneNo,
      'routeId': routeId,
      'mapLink': mapLink,
      'coordinates': {
        "latitude": coordinates.isNotEmpty ? coordinates[0] : '0',
        "longitude": coordinates.length > 1 ? coordinates[1] : '0',
      },
      'totalPrice': totalPrice,
      'totalWeightQuantity': totalWeightQuantity,
      'createdAt': createdAt.toIso8601String().split('T').first,
      'date': date.toIso8601String().split('T').first,
      'finalDate': finalDate.toIso8601String().split('T').first,
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String().split('T').first,
    };
  }

  @override
  String toString() {
    return 'Pickup('
        'obxId: $obxId, '
        'id: $id, '
        'firebaseIndex: $firebaseIndex, '
        'name: $name, '
        'item: ${itemsData.map((item) => item.id).toList()}, '
        ')';

    // 'mobileNo: $mobileNo, '
    // 'address: $address, '
    // 'area: $area, '
    // 'pincode: $pincode, '
    // 'aov: $aov, '
    // 'description: $description, '
    // 'expectedWeight: $expectedWeight, '
    // 'items: $items, '
    // 'slot: $slot, '
    // 'finalSlot: $finalSlot, '
    // 'status: $status, '
    // 'subStatus: $subStatus, '
    // 'isCompleted: $isCompleted, '
    // 'isLocked: $isLocked, '
    // 'lockedBy: $lockedBy, '
    // 'pickerId: $pickerId, '
    // 'pickerPhoneNo: $pickerPhoneNo, '
    // 'helperId: $helperId, '
    // 'helperPhoneNo: $helperPhoneNo, '
    // 'routeId: $routeId, '
    // 'mapLink: $mapLink, '
    // 'coordinates: $coordinates, '
    // 'totalPrice: $totalPrice, '
    // 'totalWeightQuantity: $totalWeightQuantity, '
    // 'createdAt: $createdAt, '
    // 'date: $date, '
    // 'finalDate: $finalDate, '
    // 'updatedAt: $updatedAt, '
    // 'completedAt: $completedAt'
    // ')';
  }
}
