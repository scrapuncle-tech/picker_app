import 'pickup.entity.dart';
import 'route.entity.dart';

class RouteInfo {
  final RouteModel? route;
  final List<Pickup> pickups;
  final List<Pickup> completedPickups;
  final bool isLoading;

  RouteInfo({
    required this.route,
    required this.pickups,
    required this.completedPickups,
    required this.isLoading,
  });

  // Create an empty state
  factory RouteInfo.empty() {
    return RouteInfo(
      route: null,
      pickups: [],
      completedPickups: [],
      isLoading: false,
    );
  }

  // CopyWith method to update state fields
  RouteInfo copyWith({
    RouteModel? route,
    List<Pickup>? pickups,
    List<Pickup>? completedPickups,
    Map<String, bool>? pickupStatus,
    bool? isLoading,
  }) {
    return RouteInfo(
      route: route ?? this.route,
      pickups: pickups ?? this.pickups,
      completedPickups: completedPickups ?? this.completedPickups,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // // Override toString for easy debugging
  @override
  String toString() {
    return '''
    RouteInfo(
      route: ${route?.toFirebase()},
      pickups: ${pickups.map((p) => {p.name: p.slot}).toList()},
      completedPickups: ${completedPickups.map((p) => {p.name: p.slot}).toList()},
      isLoading: $isLoading
    )
    ''';
  }
}
