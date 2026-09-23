import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/shifts/models/shift_model.dart';
import 'package:foodiepos/modules/shifts/widgets/open_shift_dialog.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ShiftController extends GetxController {
  final Network _network = Network.instance;

  final Rx<ShiftModel?> currentShift = Rx<ShiftModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final storage = GetStorage();
    final token = storage.read(StorageKeys.token);
    if (token != null && token.toString().trim().isNotEmpty) {
      fetchCurrentShift();
    }
  }

  bool _isEligibleForShiftPrompt() {
    final storage = GetStorage();
    final token = storage.read(StorageKeys.token);
    // User must be authenticated
    if (token == null || token.toString().trim().isEmpty) return false;

    // Must NOT be on the login screen
    if (Get.currentRoute == AppRoutes.login) return false;

    // Must be on the authenticated POS or main shell route
    if (Get.currentRoute != AppRoutes.pos && !Get.currentRoute.contains('pos')) {
      return false;
    }

    return true;
  }

  Future<void> checkAndPromptOpenShift() async {
    if (!_isEligibleForShiftPrompt()) return;

    await fetchCurrentShift();

    if (!_isEligibleForShiftPrompt()) return;

    if (currentShift.value == null) {
      await Future.delayed(const Duration(milliseconds: 350));

      if (!_isEligibleForShiftPrompt()) return;

      if (Get.context != null && currentShift.value == null) {
        if (Get.isDialogOpen != true) {
          OpenShiftDialog.show(Get.context!, this);
        }
      }
    }
  }

  Future<void> fetchCurrentShift() async {
    final storage = GetStorage();
    final token = storage.read(StorageKeys.token);
    if (token == null || token.toString().trim().isEmpty) {
      currentShift.value = null;
      return;
    }

    try {
      isLoading.value = true;
      final cashierId = storage.read(StorageKeys.cashierId);
      final cashierName = storage.read(StorageKeys.cashierName);

      final queryParams = <String, dynamic>{};
      if (cashierId != null) queryParams['cashier_id'] = cashierId.toString();
      if (cashierName != null) queryParams['cashier_name'] = cashierName.toString();

      final response = await _network.apiRequest<ShiftModel?>(
        requestType: ApiRequestType.get,
        endPoint: '/api/v1/shifts/current',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        isBearerRequired: false,
        parser: (data) {
          if (data is Map<String, dynamic>) {
            return ShiftModel.fromJson(data);
          }
          return null;
        },
      );

      if (response.success) {
        currentShift.value = response.data;
      }
    } catch (e) {
      debugPrint('Error fetching shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> openShift(double openingFloat, {String? notes}) async {
    try {
      AppLoader.show(status: 'Opening shift...');
      final storage = GetStorage();
      final cashierId = storage.read(StorageKeys.cashierId);
      final cashierName = storage.read(StorageKeys.cashierName) ?? 'Akhan';

      final response = await _network.apiRequest<ShiftModel>(
        requestType: ApiRequestType.post,
        endPoint: '/api/v1/shifts/open',
        requestData: {
          'opening_float': openingFloat,
          'cashier_id': cashierId,
          'cashier_name': cashierName,
          'notes': notes,
        },
        isBearerRequired: true,
        parser: (data) => ShiftModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        currentShift.value = response.data;
        AppLoader.showSuccess('Shift opened with Rs ${openingFloat.toStringAsFixed(0)} float');
        return true;
      }
      return false;
    } catch (e) {
      // Fallback local shift
      final storage = GetStorage();
      final cashierId = storage.read(StorageKeys.cashierId);
      final cashierName = storage.read(StorageKeys.cashierName) ?? 'Akhan';

      currentShift.value = ShiftModel(
        id: 'shift_local_${DateTime.now().millisecondsSinceEpoch}',
        cashierId: cashierId?.toString(),
        cashierName: cashierName.toString(),
        openingFloat: openingFloat,
        expectedCash: openingFloat,
        totalSales: 0.0,
        cashSales: 0.0,
        cardSales: 0.0,
        totalOrders: 0,
        status: 'open',
        openedAt: DateTime.now(),
      );
      AppLoader.showSuccess('Shift opened with Rs ${openingFloat.toStringAsFixed(0)} float (Offline)');
      return true;
    }
  }

  Future<bool> closeShift(double countedCash, {String? notes}) async {
    try {
      AppLoader.show(status: 'Reconciling shift...');
      final storage = GetStorage();
      final cashierId = storage.read(StorageKeys.cashierId);

      final response = await _network.apiRequest<ShiftModel>(
        requestType: ApiRequestType.post,
        endPoint: '/api/v1/shifts/close',
        requestData: {
          'closing_cash': countedCash,
          'cashier_id': cashierId,
          'shift_id': currentShift.value?.id,
          'notes': notes,
        },
        isBearerRequired: true,
        parser: (data) => ShiftModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        final closed = response.data!;
        final diff = closed.cashDifference ?? 0.0;
        final diffMsg = diff == 0
            ? 'Cash matched perfectly!'
            : (diff > 0 ? '+Rs ${diff.toStringAsFixed(0)} (Over)' : '-Rs ${(-diff).toStringAsFixed(0)} (Short)');

        currentShift.value = null;
        AppLoader.showSuccess('Shift closed successfully! $diffMsg');
        return true;
      }
      return false;
    } catch (e) {
      currentShift.value = null;
      AppLoader.showSuccess('Shift closed successfully (Offline)');
      return true;
    }
  }
}
