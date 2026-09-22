import 'package:foodiepos/data/models/cashier_model.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';

abstract class ILoginRepository {
  Future<BaseResponseModel<AuthDataModel>> pinLogin(String pin);
  Future<BaseResponseModel<AuthDataModel>> emailLogin({
    required String email,
    required String password,
  });
  Future<BaseResponseModel<AuthDataModel>> signUp({
    required String name,
    required String pin,
    String? email,
    String? password,
    String? phone,
    String? role,
    String? storeName,
  });
  Future<BaseResponseModel<CashierModel>> getProfile();
  Future<BaseResponseModel<dynamic>> logout();
}

class LoginRepository implements ILoginRepository {
  final Network _network;

  LoginRepository({Network? network}) : _network = network ?? Network.instance;

  @override
  Future<BaseResponseModel<AuthDataModel>> pinLogin(String pin) async {
    return await _network.apiRequest<AuthDataModel>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/auth/pin-login',
      requestData: {'pin': pin.trim()},
      isBearerRequired: false,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return AuthDataModel.fromJson(data);
        }
        return AuthDataModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  @override
  Future<BaseResponseModel<AuthDataModel>> emailLogin({
    required String email,
    required String password,
  }) async {
    return await _network.apiRequest<AuthDataModel>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/auth/login',
      requestData: {
        'email': email.trim(),
        'password': password,
      },
      isBearerRequired: false,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return AuthDataModel.fromJson(data);
        }
        return AuthDataModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  @override
  Future<BaseResponseModel<AuthDataModel>> signUp({
    required String name,
    required String pin,
    String? email,
    String? password,
    String? phone,
    String? role,
    String? storeName,
  }) async {
    return await _network.apiRequest<AuthDataModel>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/auth/signup',
      requestData: {
        'name': name.trim(),
        'pin': pin.trim(),
        if (email != null && email.isNotEmpty) 'email': email.trim(),
        if (password != null && password.isNotEmpty) 'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (role != null) 'role': role,
        if (storeName != null) 'store_name': storeName,
      },
      isBearerRequired: false,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return AuthDataModel.fromJson(data);
        }
        return AuthDataModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  @override
  Future<BaseResponseModel<CashierModel>> getProfile() async {
    return await _network.apiRequest<CashierModel>(
      requestType: ApiRequestType.get,
      endPoint: '/api/v1/auth/me',
      isBearerRequired: true,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return CashierModel.fromJson(data);
        }
        return CashierModel.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> logout() async {
    return await _network.apiRequest<dynamic>(
      requestType: ApiRequestType.post,
      endPoint: '/api/v1/auth/logout',
      isBearerRequired: true,
      parser: (data) => data,
    );
  }
}
