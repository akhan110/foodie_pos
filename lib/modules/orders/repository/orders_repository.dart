import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';

abstract class IOrdersRepository {
  Future<BaseResponseModel<List<Map<String, dynamic>>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<BaseResponseModel<Map<String, dynamic>>> getOrderById(String orderId);
  Future<BaseResponseModel<Map<String, dynamic>>> updateOrderStatus(
    String orderId,
    String status,
  );
}

class OrdersRepository implements IOrdersRepository {
  final Network _network;

  OrdersRepository({Network? network}) : _network = network ?? Network.instance;

  @override
  Future<BaseResponseModel<List<Map<String, dynamic>>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    return await _network.apiRequest<List<Map<String, dynamic>>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/orders',
      queryParameters: queryParams,
      isBearerRequired: true,
      parser: (data) {
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> getOrderById(String orderId) async {
    return await _network.apiRequest<Map<String, dynamic>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/orders/$orderId',
      isBearerRequired: true,
      parser: (data) => data is Map<String, dynamic> ? data : {},
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    return await _network.apiRequest<Map<String, dynamic>>(
      requestType: ApiRequestType.patch,
      endPoint: '/api/v1/orders/$orderId/status',
      requestData: {'status': status},
      isBearerRequired: true,
      parser: (data) => data is Map<String, dynamic> ? data : {},
    );
  }
}
