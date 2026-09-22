import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';

abstract class IOrdersRepository {
  Future<BaseResponseModel<List<OrderModel>>> getOrders({
    String? status,
    String? type,
    String? search,
  });

  Future<BaseResponseModel<OrderModel>> getOrderDetails(String orderId);

  Future<BaseResponseModel<OrderModel>> createOrder(Map<String, dynamic> data);

  Future<BaseResponseModel<OrderModel>> updateOrderStatus(String orderId, String status);
}

class OrdersRepository implements IOrdersRepository {
  final Network _network;

  OrdersRepository({Network? network}) : _network = network ?? Network.instance;

  @override
  Future<BaseResponseModel<List<OrderModel>>> getOrders({
    String? status,
    String? type,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all' && status.toLowerCase() != 'all statuses') {
      queryParams['status'] = status;
    }
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all' && type.toLowerCase() != 'all types') {
      queryParams['type'] = type;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    return await _network.apiRequest<List<OrderModel>>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/orders',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      isBearerRequired: true,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> getOrderDetails(String orderId) async {
    return await _network.apiRequest<OrderModel>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/orders/$orderId',
      isBearerRequired: true,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        return OrderModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> createOrder(Map<String, dynamic> data) async {
    return await _network.apiRequest<OrderModel>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/orders',
      requestData: data,
      isBearerRequired: true,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        return OrderModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> updateOrderStatus(String orderId, String status) async {
    return await _network.apiRequest<OrderModel>(
      requestType: ApiRequestType.patch,
      endPoint: '/api/v1/orders/$orderId/status',
      requestData: {'status': status},
      isBearerRequired: true,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        return OrderModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }
}
