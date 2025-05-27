import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/common/custom_snackbar.component.dart';
import '../../models/item.entity.dart';
import '../../models/picker.entity.dart';
import '../../models/pickup.entity.dart';
import '../../models/product.entity.dart';
import '../../models/route.entity.dart';
import '../../utilities/firebase_constants.dart';

class ReadService {
  Stream<Picker?> getPicker({required String id}) {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.pickerCollection)
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return Picker.fromFirebase(snapshot.data()!);
          } else {
            return null;
          }
        })
        .handleError((e) {
          CustomSnackBar.log(
            message: "Failed to get picker $id: $e",
            status: SnackBarType.error,
          );
        });
  }

  Stream<RouteModel?> getRoute({required String pickerId}) {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.routeCollection)
        .where('picker', isEqualTo: pickerId)
        .where(
          'scheduledDate',
          isEqualTo: DateTime.now().toIso8601String().split('T').first,
        )
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty && snapshot.docs[0].exists) {
            return RouteModel.fromFirebase({
              ...snapshot.docs[0].data(),
              'id': snapshot.docs[0].id,
            });
          } else {
            debugPrint("Route not found");
            return null;
          }
        })
        .handleError((e) {
          CustomSnackBar.log(
            message: "Failed to get route for picker $pickerId: $e",
            status: SnackBarType.error,
          );
        });
  }

  Stream<Pickup?> getPickup({required String id}) async* {
    final docStream =
        FirebaseFirestore.instance
            .collection(FirebaseConstants.pickupCollection)
            .where('pickupId', isEqualTo: id)
            .snapshots();

    await for (var snapshots in docStream) {
      try {
        final snapshot = snapshots.docs.firstOrNull;
        if (snapshot != null && snapshot.exists) {
          final rawData = snapshot.data();

          Pickup pickup = Pickup.fromFirebase({...rawData, 'id': snapshot.id});

          List<Item?> items = await Future.wait(
            pickup.items.map((id) => getItem(id: id)),
          );

          pickup.itemsData.addAll(items.whereType<Item>());
          yield pickup;
        } else {
          yield null;
        }
      } catch (e) {
        CustomSnackBar.log(
          message: "Failed to get pickup $id: $e",
          status: SnackBarType.error,
        );
        yield null;
      }
    }
  }

  Future<Item?> getItem({required String id}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection(FirebaseConstants.itemsCollection)
              .doc(id)
              .get();

      if (doc.exists && doc.data() != null) {
        return Item.fromFirebase({...doc.data()!, 'id': doc.id});
      } else {
        return null;
      }
    } catch (e) {
      CustomSnackBar.log(
        message: "Failed to get item $id: $e",
        status: SnackBarType.error,
      );
      rethrow;
    }
  }

  Stream<List<Product>> getProducts() {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.productCollection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Product.fromFirebase({...doc.data(), 'id': doc.id}))
              .toList();
        })
        .handleError((e) {
          CustomSnackBar.log(
            message: "Failed to get products: $e",
            status: SnackBarType.error,
          );
        });
  }

  Future<Pickup?> getPickupAsync({required String pickupId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.pickupCollection)
            .where('pickupId', isEqualTo: pickupId)
            .get();

    if (snapshot.docs.isNotEmpty && snapshot.docs[0].exists) {
      return Pickup.fromFirebase({
        ...snapshot.docs[0].data(),
        'id': snapshot.docs[0].id,
      });
    } else {
      return null;
    }
  }
}
