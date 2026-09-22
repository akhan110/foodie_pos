import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/data/models/cashier_model.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/modules/signup/controllers/signup_controller.dart';
import 'package:foodiepos/services/network/api_exception.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MockSignupRepository implements ILoginRepository {
  bool shouldSucceed = true;
  String? errorMessage;

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
    if (!shouldSucceed) {
      throw ApiException(
        message: errorMessage ?? 'An account with this email already exists.',
        statusCode: 400,
        type: ApiExceptionType.badRequest,
      );
    }

    return BaseResponseModel<AuthDataModel>(
      success: true,
      message: 'Welcome to BiteFlow POS, $name!',
      statusCode: 201,
      data: AuthDataModel(
        accessToken: 'mock_jwt_signup_token_999',
        tokenType: 'bearer',
        user: CashierModel(
          id: 'mock-signup-uuid',
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
  Future<BaseResponseModel<List<CashierModel>>> getCashiers() async {
    return BaseResponseModel<List<CashierModel>>(
      success: true,
      message: 'Cashiers',
      statusCode: 200,
      data: [],
    );
  }

  @override
  Future<BaseResponseModel<AuthDataModel>> pinLogin(String pin, {String? cashierId}) async =>
      throw UnimplementedError();

  @override
  Future<BaseResponseModel<AuthDataModel>> emailLogin({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<BaseResponseModel<CashierModel>> getProfile() async =>
      throw UnimplementedError();

  @override
  Future<BaseResponseModel<dynamic>> logout() async =>
      throw UnimplementedError();
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

  group('SignupController Tests', () {
    late MockSignupRepository mockRepo;
    late SignupController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockSignupRepository();
      controller = SignupController(loginRepository: mockRepo);
    });

    test('1. Validation fails if required fields are empty or PIN is invalid', () async {
      await controller.createAccount();
      expect(controller.errorMessage.value, contains('Please enter your full name'));

      controller.fullNameController.text = 'Alex Khan';
      await controller.createAccount();
      expect(controller.errorMessage.value, contains('restaurant/store name'));

      controller.storeNameController.text = 'BiteFlow Central';
      await controller.createAccount();
      expect(controller.errorMessage.value, contains('PIN must be exactly 4 digits'));

      controller.pinController.text = '123';
      await controller.createAccount();
      expect(controller.errorMessage.value, contains('PIN must be exactly 4 digits'));

      controller.pinController.text = '1234';
      controller.confirmPinController.text = '4321';
      await controller.createAccount();
      expect(controller.errorMessage.value, contains('PINs do not match'));

      controller.confirmPinController.text = '1234';
      await controller.createAccount();
      expect(controller.errorMessage.value, contains('agree to the Terms'));
    });

    test('2. Successful signup clears errors and completes', () async {
      mockRepo.shouldSucceed = true;

      controller.fullNameController.text = 'Alex Khan';
      controller.storeNameController.text = 'BiteFlow Central';
      controller.pinController.text = '1234';
      controller.confirmPinController.text = '1234';
      controller.toggleAgreeToTerms(true);

      await controller.createAccount();

      expect(controller.errorMessage.value, isEmpty);
    });
  });
}
