import 'dart:async';
import 'dart:ui';

import '../../models/objectbox_output/objectbox.g.dart';
import '../../models/product.entity.dart';
import '../firebase/read.service.dart';
import 'object_box.dart';

class OBProductService {
  ObjectBox objectbox;
  final VoidCallback? onSynced;
  StreamSubscription? _productSubscription;

  OBProductService({required this.objectbox, this.onSynced});

  void syncProducts() {
    // Cancel any existing subscription first
    _productSubscription?.cancel();

    _productSubscription = ReadService().getProducts().listen((
      List<Product> products,
    ) {
      onSynced?.call();
      List<Product> updatedProducts = [];

      for (Product currentProduct in products) {
        Product? existingProduct =
            objectbox.productBox
                .query(Product_.id.equals(currentProduct.id))
                .build()
                .findFirst();

        if (existingProduct != null) {
          updatedProducts.add(
            currentProduct.copyWith(obxId: existingProduct.obxId),
          );
        } else {
          updatedProducts.add(currentProduct);
        }
      }

      objectbox.productBox.putMany(updatedProducts);
    });
  }

  Stream<List<Product>> getProducts() {
    return objectbox.productBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  void dispose() {
    _productSubscription?.cancel();
  }
}
