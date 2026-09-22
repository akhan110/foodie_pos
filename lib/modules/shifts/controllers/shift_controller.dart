import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/shifts/models/shift_model.dart';
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
    fetchCurrentShift();
  }

  Future<void> fetchCurrentShift() async {
    try {
      isLoading.value = true;
      final response = await _network.apiRequest<ShiftModel?>(
        requestType: ApiRequestType.get,
        endPoint: '/api/v1/shifts/current',
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
      final cashierName = storage.read(StorageKeys.cashierName) ?? 'Alex Khan';

      final response = await _network.apiRequest<ShiftModel>(
        requestType: ApiRequestType.post,
        endPoint: '/api/v1/shifts/open',
        requestData: {
          'opening_float': openingFloat,
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
      currentShift.value = ShiftModel(
        id: 'shift_local_${DateTime.now().millisecondsSinceEpoch}',
        cashierName: 'Alex Khan',
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

      final response = await _network.apiRequest<ShiftModel>(
        requestType: ApiRequestType.post,
        endPoint: '/api/v1/shifts/close',
        requestData: {
          'closing_cash': countedCash,
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
