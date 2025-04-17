import 'package:objectbox/objectbox.dart';

@Entity()
class Picker {
  @Id()
  int obxId;

  @Unique()
  @Index()
  String id;
  //
  String name;
  String email;
  String licenseNo;
  String phoneNo;
  // status fields
  bool isAvailable;
  bool isDriver;
  bool isHelper;
  bool isOnLeave;
  bool isPicker;
  bool isWorking;
  //
  String routeName;

  String assignedVehicleId;
  String assignedVehicleName;

  Picker({
    this.obxId = 0,
    required this.id,
    required this.name,
    required this.email,
    required this.licenseNo,
    required this.phoneNo,
    required this.isAvailable,
    required this.isDriver,
    required this.isHelper,
    required this.isOnLeave,
    required this.isPicker,
    required this.isWorking,
    required this.routeName,
    required this.assignedVehicleId,
    required this.assignedVehicleName,
  });

  static Picker fromFirebase(Map<String, dynamic> data) {
    return Picker(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      licenseNo: data['licenseNo'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      isDriver: data['isDriver'] ?? false,
      isHelper: data['isHelper'] ?? false,
      isOnLeave: data['isOnLeave'] ?? false,
      isPicker: data['isPicker'] ?? false,
      isWorking: data['isWorking'] ?? false,
      routeName: data['routeName'] ?? '',
      assignedVehicleId: data['assignedVehicleId'] ?? '',
      assignedVehicleName: data['assignedVehicleName'] ?? '',
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'licenseNo': licenseNo,
      'phoneNo': phoneNo,
      'isAvailable': isAvailable,
      'isDriver': isDriver,
      'isHelper': isHelper,
      'isOnLeave': isOnLeave,
      'isPicker': isPicker,
      'isWorking': isWorking,
      'routeName': routeName,
      'assignedVehicleId': assignedVehicleId,
      'assignedVehicleName': assignedVehicleName,
    };
  }

  Picker copyWith({
    int? obxId,
    String? id,
    String? name,
    String? email,
    String? licenseNo,
    String? phoneNo,
    bool? isAvailable,
    bool? isDriver,
    bool? isHelper,
    bool? isOnLeave,
    bool? isPicker,
    bool? isWorking,
    String? routeName,
    String? assignedVehicleId,
    String? assignedVehicleName,
  }) {
    return Picker(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      licenseNo: licenseNo ?? this.licenseNo,
      phoneNo: phoneNo ?? this.phoneNo,
      isAvailable: isAvailable ?? this.isAvailable,
      isDriver: isDriver ?? this.isDriver,
      isHelper: isHelper ?? this.isHelper,
      isOnLeave: isOnLeave ?? this.isOnLeave,
      isPicker: isPicker ?? this.isPicker,
      isWorking: isWorking ?? this.isWorking,
      routeName: routeName ?? this.routeName,
      assignedVehicleId: assignedVehicleId ?? this.assignedVehicleId,
      assignedVehicleName: assignedVehicleName ?? this.assignedVehicleName,
    );
  }
}
