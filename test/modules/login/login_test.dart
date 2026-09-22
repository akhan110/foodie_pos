import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/data/models/cashier_model.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/login/controllers/login_controller.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/services/network/api_exception.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MockLoginRepository implements ILoginRepository {
  bool shouldSucceed = true;
  String? errorMessage;

  @override
  Future<BaseResponseModel<List<CashierModel>>> getCashiers() async {
    return BaseResponseModel<List<CashierModel>>(
      success: true,
      message: 'Active cashiers retrieved successfully',
      statusCode: 200,
      data: [
        CashierModel(
          id: 'mock-uuid-1234',
          name: 'Alex Khan',
          email: 'alex@foodiepos.com',
          role: 'cashier',
          storeName: 'Store #01',
          isActive: true,
        ),
        CashierModel(
          id: 'mock-uuid-5678',
          name: 'Akhan',
          email: 'akhan@kucks.com',
          role: 'manager',
          storeName: 'Kucks',
          isActive: true,
        ),
      ],
    );
  }

  @override
  Future<BaseResponseModel<AuthDataModel>> pinLogin(String pin, {String? cashierId}) async {
    if (!shouldSucceed) {
      throw ApiException(
        message: errorMessage ?? 'Invalid 4-digit PIN. Please try again.',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    final isAkhan = cashierId == 'mock-uuid-5678';
    return BaseResponseModel<AuthDataModel>(
      success: true,
      message: isAkhan ? 'Welcome back, Akhan!' : 'Welcome back, Alex Khan!',
      statusCode: 200,
      data: AuthDataModel(
        accessToken: 'mock_jwt_token_12345',
        tokenType: 'bearer',
        user: CashierModel(
          id: isAkhan ? 'mock-uuid-5678' : 'mock-uuid-1234',
          name: isAkhan ? 'Akhan' : 'Alex Khan',
          email: isAkhan ? 'akhan@kucks.com' : 'alex@foodiepos.com',
          role: isAkhan ? 'manager' : 'cashier',
          storeName: isAkhan ? 'Kucks' : 'Store #01',
          isActive: true,
        ),
      ),
    );
  }

  @override
  Future<BaseResponseModel<AuthDataModel>> emailLogin({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
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
    return BaseResponseModel<AuthDataModel>(
      success: true,
      message: 'Account created successfully.',
      statusCode: 201,
      data: AuthDataModel(
        accessToken: 'mock_jwt_signup_token',
        tokenType: 'bearer',
        user: CashierModel(
          id: 'new-user-uuid',
          name: name,
          email: email,
          role: role ?? 'manager',
          storeName: storeName ?? 'BiteFlow Store #01',
          isActive: true,
        ),
      ),
    );
  }

  @override
  Future<BaseResponseModel<CashierModel>> getProfile() async {
    throw UnimplementedError();
  }

  @override
  Future<BaseResponseModel<dynamic>> logout() async {
    return BaseResponseModel(
      success: true,
      message: 'Cashier logged out successfully',
      statusCode: 200,
      data: null,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
    await GetStorage.init();
  });

  group('LoginController & Repository Tests', () {
    late MockLoginRepository mockRepo;
    late LoginController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockLoginRepository();
      controller = LoginController(loginRepository: mockRepo);
    });

    test('1. Keypad number input updates pin observable', () {
      controller.onNumberPressed('1');
      controller.onNumberPressed('2');
      expect(controller.pin.value, '12');

      controller.onDeletePressed();
      expect(controller.pin.value, '1');

      controller.clearPin();
      expect(controller.pin.value, '');
    });

    test('2. Successful PIN login triggers repository and navigates', () async {
      mockRepo.shouldSucceed = true;

      controller.onNumberPressed('1');
      controller.onNumberPressed('2');
      controller.onNumberPressed('3');
      controller.onNumberPressed('4');

      // Wait for async verifyPin execution
      await Future.delayed(const Duration(milliseconds: 150));

      expect(controller.errorMessage.value, isEmpty);
    });

    test('3. Failed PIN login sets error message', () async {
      mockRepo.shouldSucceed = false;
      mockRepo.errorMessage = 'Invalid 4-digit PIN. Please try again.';

      controller.onNumberPressed('9');
      controller.onNumberPressed('9');
      controller.onNumberPressed('9');
      controller.onNumberPressed('9');

      await Future.delayed(const Duration(milliseconds: 150));

      expect(controller.errorMessage.value, contains('Invalid 4-digit PIN'));
    });

    test('4. Logout API succeeds and returns 200 response', () async {
      final response = await mockRepo.logout();
      expect(response.success, isTrue);
      expect(response.statusCode, 200);
      expect(response.message, contains('logged out successfully'));
    });

    test('5. Cashier dropdown loads and allows selecting a user', () async {
      await controller.loadCashiers();
      expect(controller.cashiers.length, 2);
      expect(controller.selectedCashier.value?.name, 'Alex Khan');

      // Select Akhan
      controller.selectCashier(controller.cashiers.last);
      expect(controller.selectedCashier.value?.name, 'Akhan');
      expect(controller.selectedCashier.value?.storeName, 'Kucks');

      // Login as Akhan
      controller.onNumberPressed('1');
      controller.onNumberPressed('2');
      controller.onNumberPressed('3');
      controller.onNumberPressed('4');

      await Future.delayed(const Duration(milliseconds: 150));
      expect(controller.errorMessage.value, isEmpty);
      expect(GetStorage().read('cashier_name'), 'Akhan');
      expect(GetStorage().read('cashier_store'), 'Kucks');
    });
  });
}
