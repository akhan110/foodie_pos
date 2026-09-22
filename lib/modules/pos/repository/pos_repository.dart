import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';

abstract class IPosRepository {
  Future<BaseResponseModel<List<ProductCategoryModel>>> getCategories();
  Future<BaseResponseModel<List<ProductModel>>> getProducts({String? categoryId});
  Future<BaseResponseModel<Map<String, dynamic>>> createOrder(Map<String, dynamic> orderPayload);
}

class PosRepository implements IPosRepository {
  final Network _network;

  PosRepository({Network? network}) : _network = network ?? Network.instance;

  @override
  Future<BaseResponseModel<List<ProductCategoryModel>>> getCategories() async {
    return await _network.apiRequest<List<ProductCategoryModel>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/menu/categories',
      isBearerRequired: true,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => ProductCategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<BaseResponseModel<List<ProductModel>>> getProducts({String? categoryId}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }

    return await _network.apiRequest<List<ProductModel>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/menu/products',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      isBearerRequired: true,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> orderPayload,
  ) async {
    return await _network.apiRequest<Map<String, dynamic>>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/orders',
      requestData: orderPayload,
      isBearerRequired: true,
      parser: (data) => data is Map<String, dynamic> ? data : {},
    );
  }
}
