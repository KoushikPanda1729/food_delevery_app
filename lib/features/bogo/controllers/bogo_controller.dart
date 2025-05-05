import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/features/bogo/domain/services/bogo_service_interface.dart';

class BogoController extends GetxController implements GetxService {
  final BogoServiceInterface bogoServiceInterface;
  BogoController({required this.bogoServiceInterface});

  List<Product>? _bogoProductList;
  List<Product>? get bogoProductList => _bogoProductList;

  Future<void> getBogoProductList(bool reload, bool notify, {String? type}) async {
    if(reload) {
      _bogoProductList = null;
    }
    if(notify) {
      update();
    }
    if(_bogoProductList == null || reload) {
      _bogoProductList = await bogoServiceInterface.getBogoProductList(type: type);
      update();
    }
  }
}