import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/product.entity.dart';
import '../services/objectbox/product.service.dart';

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]) {
    getProducts();
  }

  void getProducts() async {
    OBProductService(objectbox: objectbox!).getProducts().listen((products) {
      state = products;
    });
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) => ProductsNotifier(),
);
