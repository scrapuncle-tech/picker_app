import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/item.entity.dart';
import '../../models/picker.entity.dart';
import '../../models/pickup.entity.dart';
import '../../models/product.entity.dart';
import '../../models/route.entity.dart';
import '../../utilities/firebase_constants.dart';

class ReadService {
  Stream<Picker> getPicker({required String id}) {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.pickerCollection)
        .doc(id)
        .snapshots()
        .map((snapshot) {
          // Check if the snapshot exists
          if (snapshot.exists) {
            Picker picker = Picker.fromFirebase(snapshot.data()!);
            return picker;
          } else {
            throw Exception("Picker not found");
          }
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
          // Check if the snapshot exists
          if (snapshot.docs.isNotEmpty && snapshot.docs[0].exists) {
            RouteModel route = RouteModel.fromFirebase({
              ...snapshot.docs[0].data(),
              'id': snapshot.docs[0].id,
            });

            return route;
          } else {
            debugPrint("Route not found");
            return null;
          }
        });
  }

  Stream<Pickup> getPickup({required String id}) async* {
    try {
      final docStream =
          FirebaseFirestore.instance
              .collection(FirebaseConstants.pickupCollection)
              .doc(id)
              .snapshots();

      await for (var snapshot in docStream) {
        if (!snapshot.exists) {
          throw Exception("pickup not found");
        }

        Pickup pickup = Pickup.fromFirebase({
          ...snapshot.data()!,
          'id': snapshot.id,
        });

        List<Item> items = await Future.wait(
          pickup.items.map((id) => getItem(id: id)),
        );

        pickup.itemsData.addAll(items);
        yield pickup; // Re-emit with itemsData populated
      }
    } catch (e) {
      debugPrint("Error on fetching the pickup : $id");
    }
  }

  Future<Item> getItem({required String id}) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.itemsCollection)
            .doc(id)
            .get();

    // Check if the snapshot exists
    if (documentSnapshot.exists) {
      return Item.fromFirebase({
        ...documentSnapshot.data()!,
        'id': documentSnapshot.id,
      });
    } else {
      throw Exception("Item not found");
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
        });
  }
}
