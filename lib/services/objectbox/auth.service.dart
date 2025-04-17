import 'package:flutter/material.dart';

import '../../models/picker.entity.dart';
import '../firebase/read.service.dart';
import 'object_box.dart';
import 'dart:async';

class OBAuthService {
  ObjectBox objectbox;
  StreamSubscription? _pickerSubscription;

  OBAuthService({required this.objectbox});

  void syncPicker() {
    _pickerSubscription?.cancel();

    Picker? existingPickerData =
        objectbox.pickerBox.query().build().find().firstOrNull;

    if (existingPickerData != null) {
      _pickerSubscription = ReadService()
          .getPicker(id: existingPickerData.id)
          .listen((pickerData) {
            objectbox.pickerBox.put(
              pickerData.copyWith(obxId: existingPickerData.obxId),
            );
          });
    } else {
      int removedObjCount = objectbox.pickerBox.removeAll();
      debugPrint("RemovedObjCount: $removedObjCount");
    }
  }

  Stream<Picker?> getPicker() {
    return objectbox.pickerBox
        .query()
        .watch(triggerImmediately: true)
        .map((data) => data.findFirst());
  }

  void setPicker(Picker picker) {
    objectbox.pickerBox.put(picker);
  }

  void dispose() {
    _pickerSubscription?.cancel();
  }
}
