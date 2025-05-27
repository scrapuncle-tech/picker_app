import 'package:objectbox/objectbox.dart';

@Entity()
class Product {
  @Id()
  int obxId;

  @Unique(onConflict: ConflictStrategy.replace)
  String id;
  //
  String name;
  String price;
  String unit;

  Product({
    this.obxId = 0,
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
  });

  Product copyWith({
    int? obxId,
    String? id,
    String? name,
    String? price,
    String? unit,
  }) {
    return Product(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
    );
  }

  static Product fromFirebase(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? '',
      unit: data['unit'] ?? '',
    );
  }

  Map<String, dynamic> toFirebase() {
    return {'id': id, 'name': name, 'price': price, 'unit': unit};
  }

  @override
  String toString() {
    return 'Product('
        'obxId: $obxId, '
        'id: $id, '
        'name: $name, '
        'price: $price, '
        'unit: $unit'
        ')';
  }
}
