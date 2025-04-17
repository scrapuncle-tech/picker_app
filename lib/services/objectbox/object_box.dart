import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/item.entity.dart';
import '../../models/local_pickup.entity.dart';
import '../../models/objectbox_output/objectbox.g.dart';
import '../../models/picker.entity.dart';
import '../../models/pickup.entity.dart';
import '../../models/product.entity.dart';
import '../../models/route.entity.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "obx"));
    return ObjectBox._create(store);
  }

  ///
  /// ALL BOX INSTANCE
  ///
  Box<Picker> get pickerBox => store.box<Picker>();
  Box<RouteModel> get routeBox => store.box<RouteModel>();
  Box<Pickup> get pickupBox => store.box<Pickup>();
  Box<Item> get itemBox => store.box<Item>();
  Box<Product> get productBox => store.box<Product>();
  Box<LocalPickup> get localStatePickupBox => store.box<LocalPickup>();
}
