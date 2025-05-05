import 'package:stackfood_multivendor/common/models/product_model.dart';

abstract class BogoServiceInterface {
  Future<List<Product>?> getBogoProductList({String? type});
}