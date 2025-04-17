import 'package:objectbox/objectbox.dart';
import 'pickup.entity.dart';
import 'product.entity.dart';

@Entity()
class Item {
  @Id()
  int obxId;

  @Unique()
  @Index()
  String id;

  /// Transient Product object not stored in ObjectBox
  @Transient()
  Product? _product;

  /// Backed Product relation stored in ObjectBox
  final ToOne<Product> productRef = ToOne<Product>();

  final pickup = ToOne<Pickup>();

  // Getter for product that uses either the transient field or relation
  Product get product => _product ?? productRef.target!;

  // Setter for product that updates both the transient field and relation
  set product(Product p) {
    _product = p;
    productRef.target = p;
  }

  @Property(type: PropertyType.date)
  DateTime createdAt;

  List<String>? localImagePaths;
  List<String>? imageUrls;
  bool isUploaded;
  double totalPrice;
  double? customPrice;
  double weight;
  double quantity;
  List<String> coordinates;

  Item({
    this.obxId = 0,
    required this.id,
    required this.createdAt,
    this.customPrice,
    required this.isUploaded,
    Product? product,
    this.localImagePaths,
    this.imageUrls,
    this.totalPrice = 0,
    this.weight = 0,
    this.quantity = 0,
    this.coordinates = const [],
  }) {
    if (product != null) {
      this.product = product;
    }
  }

  Item copyWith({
    int? obxId,
    String? id,
    DateTime? createdAt,
    double? customPrice,
    bool? isUploaded,
    Product? product,
    List<String>? localImagePaths,
    List<String>? imageUrls,
    double? totalPrice,
    double? weight,
    double? quantity,
    List<String>? coordinates,
  }) {
    final item = Item(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      customPrice: customPrice ?? this.customPrice,
      isUploaded: isUploaded ?? this.isUploaded,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      imageUrls: imageUrls ?? this.imageUrls,
      totalPrice: totalPrice ?? this.totalPrice,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      coordinates: coordinates ?? this.coordinates,
    );

    // Set product after creation
    item.product = product ?? this.product;
    return item;
  }

  static Item fromFirebase(Map<String, dynamic> data) {
    final product = Product.fromFirebase(data['product']);

    final item = Item(
      id: data['id'],
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      customPrice: data['customPrice']?.toDouble(),
      isUploaded: data['isUploaded'] ?? false,
      localImagePaths: List<String>.from(data['localImagePaths'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      coordinates: List<String>.from(data['coordinates'] ?? []),
    );

    // Set product after creation
    item.product = product;
    return item;
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String().split('T').first,
      'customPrice': customPrice,
      'isUploaded': isUploaded,
      'product': product.toFirebase(),
      'imageUrls': imageUrls,
      'totalPrice': totalPrice,
      'weight': weight,
      'quantity': quantity,
      'coordinates': coordinates,
    };
  }

  @override
  String toString() {
    return 'Item('
        'obxId: $obxId, '
        'id: $id, '
        'createdAt: ${createdAt.toIso8601String()}, '
        'customPrice: $customPrice, '
        'isUploaded: $isUploaded, '
        'product: ${product.toString()}, '
        'localImagePaths: $localImagePaths, '
        'imageUrls: $imageUrls, '
        'totalPrice: $totalPrice, '
        'weight: $weight, '
        'quantity: $quantity, '
        'coordinates: $coordinates'
        ')';
  }
}
