import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/item.entity.dart';
import '../../models/notification.entity.dart';
import '../../models/pickup.entity.dart';
import '../../utilities/firebase_constants.dart';

/// Keeps track of pickups currently being uploaded to avoid duplicate uploads

class WriteService {
  /// Uploads item images and saves both items and pickup to Firestore.
  /// Returns a Stream<String> that emits status updates:
  /// - 'started': When the upload process begins
  /// - 'uploading_images': When image upload is in progress
  /// - 'saving_items': When saving items to Firestore
  /// - 'saving_pickup': When saving pickup to Firestore
  /// - 'completed': When the entire process is successfully completed
  /// - 'failed: {error message}': If any step fails
  Stream<String> putPickup({required Pickup pickup}) async* {
    try {
      yield 'started';
      debugPrint("NEED to push to firebase : $pickup");

      List<Item> itemsNotUploaded =
          pickup.itemsData.where((d) => !d.isUploaded).toList();

      // Step 1: Upload all item images and get download URLs
      yield 'uploading_images';
      Map<String, List<String>> itemImageUrls = await _uploadItemImages(
        itemsNotUploaded,
      );

      // Step 2: Save all items to Firestore with uploaded image URLs
      yield 'saving_items';
      List<String> itemIds = await _saveItemsToFirestore(
        itemsNotUploaded,
        itemImageUrls,
      );

      debugPrint("Item IDS: $itemIds ");

      // Step 3: Save the pickup entry to Firestore with reference to item IDs
      yield 'saving_pickup';
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.pickupCollection)
          .doc(pickup.id)
          .set(pickup.toFirebase(itemIds: itemIds));

      yield 'completed';
    } catch (e) {
      debugPrint("Error pushing to firebase: $e");
      yield 'failed: ${e.toString()}';
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
        isUploaded: true,
      );

      await docRef.set(updatedItem.toFirebase(), SetOptions(merge: true));
      itemIds.add(docRef.id);
    }

    return itemIds;
  }

  /// Saves a notification to Firestore.
  /// Returns a Future<bool> indicating success or failure.
  Future<bool> putNotification({
    required NotificationEntity notification,
  }) async {
    try {
      debugPrint("Pushing notification to Firebase: ${notification.title}");

      // Generate a new document ID if not provided
      String docId =
          notification.id.isNotEmpty
              ? notification.id
              : FirebaseFirestore.instance
                  .collection(FirebaseConstants.notificationCollection)
                  .doc()
                  .id;

      // Update the notification with the new ID if it was generated
      NotificationEntity updatedNotification =
          notification.id.isNotEmpty
              ? notification
              : notification.copyWith(id: docId);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.notificationCollection)
          .doc(docId)
          .set(updatedNotification.toFirebase(), SetOptions(merge: true));

      debugPrint("Successfully pushed notification to Firebase");
      return true;
    } catch (e) {
      debugPrint("Error pushing notification to Firebase: $e");
      return false;
    }
  }
}
