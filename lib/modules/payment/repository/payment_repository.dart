import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';

abstract class IPaymentRepository {
  Future<BaseResponseModel<Map<String, dynamic>>> processPayment({
    required String orderId,
    required String paymentMethod,
    required double amount,
    double? changeDue,
  });
}

class PaymentRepository implements IPaymentRepository {
  final Network _network;

  PaymentRepository({Network? network}) : _network = network ?? Network.instance;

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> processPayment({
    required String orderId,
    required String paymentMethod,
    required double amount,
    double? changeDue,
  }) async {
    return await _network.apiRequest<Map<String, dynamic>>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/payments/process',
      requestData: {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount': amount,
        if (changeDue != null) 'change_due': changeDue,
      },
      isBearerRequired: true,
      parser: (data) => data is Map<String, dynamic> ? data : {},
    );
  }
}
