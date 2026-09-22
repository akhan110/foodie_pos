import 'package:dio/dio.dart' as dio;
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/deals/models/deal_model.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';

abstract class IPosRepository {
  Future<BaseResponseModel<List<ProductCategoryModel>>> getCategories();
  Future<BaseResponseModel<List<ProductModel>>> getProducts({
    String? categoryId,
    bool includeInactive = false,
  });
  Future<BaseResponseModel<ProductModel>> createProduct(Map<String, dynamic> data);
  Future<BaseResponseModel<ProductModel>> updateProduct(String id, Map<String, dynamic> data);
  Future<BaseResponseModel<dynamic>> deleteProduct(String id);

  Future<BaseResponseModel<List<ProductExtraItem>>> getAddons({String? categoryId});
  Future<BaseResponseModel<ProductExtraItem>> createAddon(Map<String, dynamic> data);
  Future<BaseResponseModel<ProductExtraItem>> updateAddon(String id, Map<String, dynamic> data);
  Future<BaseResponseModel<dynamic>> deleteAddon(String id);

  Future<BaseResponseModel<List<ProductSizeOption>>> getSizeOptions({String? categoryId});
  Future<BaseResponseModel<ProductSizeOption>> createSizeOption(Map<String, dynamic> data);
  Future<BaseResponseModel<dynamic>> deleteSizeOption(String id);
  Future<BaseResponseModel<String>> uploadImage(String filePath, {List<int>? bytes, String? filename});
  Future<BaseResponseModel<Map<String, dynamic>>> createOrder(Map<String, dynamic> orderPayload);
  Future<BaseResponseModel<List<DealModel>>> getDeals({bool activeOnly = true});
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
  Future<BaseResponseModel<List<ProductModel>>> getProducts({
    String? categoryId,
    bool includeInactive = false,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      queryParams['category_id'] = categoryId;
    }
    if (includeInactive) {
      queryParams['include_inactive'] = true;
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
  Future<BaseResponseModel<ProductModel>> createProduct(Map<String, dynamic> data) async {
    return await _network.apiRequest<ProductModel>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/menu/products',
      requestData: data,
      isBearerRequired: true,
      parser: (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<ProductModel>> updateProduct(String id, Map<String, dynamic> data) async {
    return await _network.apiRequest<ProductModel>(
      requestType: ApiRequestType.put,
      endPoint: '/api/v1/menu/products/$id',
      requestData: data,
      isBearerRequired: true,
      parser: (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> deleteProduct(String id) async {
    return await _network.apiRequest<dynamic>(
      requestType: ApiRequestType.delete,
      endPoint: '/api/v1/menu/products/$id',
      isBearerRequired: true,
      parser: (data) => data,
    );
  }

  @override
  Future<BaseResponseModel<List<ProductExtraItem>>> getAddons({String? categoryId}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      queryParams['category_id'] = categoryId;
    }

    return await _network.apiRequest<List<ProductExtraItem>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/menu/addons',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      isBearerRequired: false,
      parser: (data) {
        if (data is List) {
          return data.map((item) {
            final map = item as Map<String, dynamic>;
            return ProductExtraItem(
              id: map['id']?.toString() ?? '',
              name: map['name']?.toString() ?? '',
              price: (map['price'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<BaseResponseModel<ProductExtraItem>> createAddon(Map<String, dynamic> data) async {
    return await _network.apiRequest<ProductExtraItem>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/menu/addons',
      requestData: data,
      isBearerRequired: true,
      parser: (item) {
        final map = item as Map<String, dynamic>;
        return ProductExtraItem(
          id: map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
        );
      },
    );
  }

  @override
  Future<BaseResponseModel<ProductExtraItem>> updateAddon(String id, Map<String, dynamic> data) async {
    return await _network.apiRequest<ProductExtraItem>(
      requestType: ApiRequestType.put,
      endPoint: '/api/v1/menu/addons/$id',
      requestData: data,
      isBearerRequired: true,
      parser: (item) {
        final map = item as Map<String, dynamic>;
        return ProductExtraItem(
          id: map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
        );
      },
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> deleteAddon(String id) async {
    return await _network.apiRequest<dynamic>(
      requestType: ApiRequestType.delete,
      endPoint: '/api/v1/menu/addons/$id',
      isBearerRequired: true,
      parser: (data) => data,
    );
  }

  @override
  Future<BaseResponseModel<List<ProductSizeOption>>> getSizeOptions({String? categoryId}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      queryParams['category_id'] = categoryId;
    }

    return await _network.apiRequest<List<ProductSizeOption>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/menu/sizes',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      isBearerRequired: false,
      parser: (data) {
        if (data is List) {
          return data.map((item) {
            final map = item as Map<String, dynamic>;
            return ProductSizeOption(
              id: map['id']?.toString() ?? '',
              name: map['name']?.toString() ?? '',
              extraPrice: (map['extra_price'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<BaseResponseModel<ProductSizeOption>> createSizeOption(Map<String, dynamic> data) async {
    return await _network.apiRequest<ProductSizeOption>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/menu/sizes',
      requestData: data,
      isBearerRequired: true,
      parser: (item) {
        final map = item as Map<String, dynamic>;
        return ProductSizeOption(
          id: map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          extraPrice: (map['extra_price'] as num?)?.toDouble() ?? 0.0,
        );
      },
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> deleteSizeOption(String id) async {
    return await _network.apiRequest<dynamic>(
      requestType: ApiRequestType.delete,
      endPoint: '/api/v1/menu/sizes/$id',
      isBearerRequired: true,
      parser: (data) => data,
    );
  }

  @override
  Future<BaseResponseModel<String>> uploadImage(
    String filePath, {
    List<int>? bytes,
    String? filename,
  }) async {
    final dio.FormData formData;
    if (bytes != null && bytes.isNotEmpty) {
      formData = dio.FormData.fromMap({
        'file': dio.MultipartFile.fromBytes(
          bytes,
          filename: filename ?? 'upload.jpg',
        ),
      });
    } else {
      formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          filePath,
          filename: filename ?? filePath.split(RegExp(r'[\\/]')).last,
        ),
      });
    }

    return await _network.apiRequest<String>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/menu/upload-image',
      requestData: formData,
      isBearerRequired: true,
      parser: (data) {
        if (data is Map && data['image_url'] != null) {
          return data['image_url'].toString();
        }
        return '';
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

  @override
  Future<BaseResponseModel<List<DealModel>>> getDeals({bool activeOnly = true}) async {
    return await _network.apiRequest<List<DealModel>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/deals',
      queryParameters: activeOnly ? {'status': 'active'} : null,
      isBearerRequired: true,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => DealModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
