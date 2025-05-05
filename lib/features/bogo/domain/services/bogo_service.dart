import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/bogo/domain/repositories/bogo_repository_interface.dart';
import 'package:stackfood_multivendor/features/bogo/domain/services/bogo_service_interface.dart';

class BogoService implements BogoServiceInterface {
  final BogoRepositoryInterface bogoRepositoryInterface;
  BogoService({required this.bogoRepositoryInterface});
  
  @override
  Future<List<Product>?> getBogoProductList({String? type}) async {
    return await bogoRepositoryInterface.getList(type: type);
  }
  
}