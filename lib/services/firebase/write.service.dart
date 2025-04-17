import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/item.entity.dart';
import '../../models/pickup.entity.dart';
import '../../utilities/firebase_constants.dart';

/// Keeps track of pickups currently being uploaded to avoid duplicate uploads

class WriteService {
  /// Uploads item images and saves both items and pickup to Firestore.
  Future<void> putPickup({required Pickup pickup}) async {
    try {
      print("NEED to push to firebase : $pickup");
      // Step 1: Upload all item images and get download URLs
      Map<String, List<String>> itemImageUrls = await _uploadItemImages(
        pickup.itemsData,
      );

      // Step 2: Save all items to Firestore with uploaded image URLs
      List<String> itemIds = await _saveItemsToFirestore(
        pickup.itemsData,
        itemImageUrls,
      );

      print("Item IDS: $itemIds ");

      // Step 3: Save the pickup entry to Firestore with reference to item IDs
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.pickupCollection)
          .doc(pickup.id)
          .set(pickup.toFirebase(itemIds: itemIds), SetOptions(merge: true));
    } catch (e) {
      // Optional: handle errors or rethrow
      rethrow;
    } finally {
      debugPrint("Done pushing to firebase");
    }
  }

  /// Uploads images for each item and maps their IDs to the uploaded URLs.
  Future<Map<String, List<String>>> _uploadItemImages(
    List<Item> itemsList,
  ) async {
    Map<String, List<String>> itemImageUrls = {};

    for (Item item in itemsList) {
      if (item.imageUrls != null && item.imageUrls!.isNotEmpty) {
        itemImageUrls[item.id] = item.imageUrls!;
        continue;
      }

      if (item.localImagePaths != null && item.localImagePaths!.isNotEmpty) {
        List<String> uploadedUrls = [];

        for (String imagePath in item.localImagePaths!) {
          try {
            String imageUrl = await _uploadImageToStorage(imagePath);
            uploadedUrls.add(imageUrl);
          } catch (_) {
            // Optional: log or skip
          }
        }

        itemImageUrls[item.id] = uploadedUrls;
      } else {
        itemImageUrls[item.id] = [];
      }
    }

    return itemImageUrls;
  }

  /// Uploads a single image file to Firebase Storage and returns its URL.
  Future<String> _uploadImageToStorage(String filePath) async {
    File file = File(filePath);
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    Reference storageRef = FirebaseStorage.instance.ref().child(
      'items/$fileName',
    );

    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;

    return await taskSnapshot.ref.getDownloadURL();
  }

  /// Saves item data to Firestore and returns their new document IDs.
  Future<List<String>> _saveItemsToFirestore(
    List<Item> itemsList,
    Map<String, List<String>> itemImageUrls,
  ) async {
    List<String> itemIds = [];

    for (Item item in itemsList) {
      DocumentReference docRef =
          FirebaseFirestore.instance
              .collection(FirebaseConstants.itemsCollection)
              .doc();

      Item updatedItem = item.copyWith(
        id: docRef.id,
        imageUrls: itemImageUrls[item.id],
      );

      await docRef.set(updatedItem.toFirebase(), SetOptions(merge: true));
      itemIds.add(docRef.id);
    }

    return itemIds;
  }
}
