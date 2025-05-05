import 'package:get/get_connect/http/src/response/response.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

import 'bogo_repository_interface.dart';

class BogoRepository implements BogoRepositoryInterface {
  final ApiClient apiClient;
  BogoRepository({required this.apiClient});

  @override
  Future<List<Product>?> getList({int? offset, String? type}) async {
    List<Product>? bogoProductList;
    String url = AppConstants.bogoListUri;
    if(type != null){
      url = '$url?restaurant_id=$type';
    }
    Response response = await apiClient.getData(url);
    if (response.statusCode == 200) {
      bogoProductList = [];
      bogoProductList.addAll(ProductModel.fromJson(response.body).products!);
    }
    return bogoProductList;
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    // TODO: implement update
    throw UnimplementedError();
  }


}