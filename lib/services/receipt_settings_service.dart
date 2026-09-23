import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReceiptSettings {
  final String storeName;
  final String branchName;
  final String address;
  final String phone;
  final String taxNumber;
  final String minNumber;
  final String terminalId;
  final String footerMessage;
  final double vatRate;

  const ReceiptSettings({
    required this.storeName,
    required this.branchName,
    required this.address,
    required this.phone,
    required this.taxNumber,
    required this.minNumber,
    required this.terminalId,
    required this.footerMessage,
    required this.vatRate,
  });
}

class ReceiptSettingsService extends GetxService {
  static ReceiptSettingsService get instance => Get.find<ReceiptSettingsService>();

  final _storage = GetStorage();

  static const _keyStoreName = 'receipt_store_name';
  static const _keyBranchName = 'receipt_branch_name';
  static const _keyAddress = 'receipt_address';
  static const _keyPhone = 'receipt_phone';
  static const _keyTaxNumber = 'receipt_tax_number';
  static const _keyMinNumber = 'receipt_min_number';
  static const _keyTerminalId = 'receipt_terminal_id';
  static const _keyFooterMessage = 'receipt_footer_message';
  static const _keyVatRate = 'receipt_vat_rate';

  final Rx<ReceiptSettings> settings = const ReceiptSettings(
    storeName: 'BITEFLOW GENERAL STORE',
    branchName: 'Store #01 • Main Branch',
    address: '151 Commercial Ave, Blue Area, Islamabad',
    phone: 'Tel: +92 51 8899000',
    taxNumber: 'VAT Reg TIN: 000-887-213-0000',
    minNumber: 'MIN: 123456789',
    terminalId: 'POS #01',
    footerMessage: 'THIS IS YOUR OFFICIAL RECEIPT\nTHANK YOU, PLEASE COME AGAIN!',
    vatRate: 16.0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    final storeName = _storage.read<String>(_keyStoreName) ?? 'BITEFLOW GENERAL STORE';
    final branchName = _storage.read<String>(_keyBranchName) ?? 'Store #01 • Main Branch';
    final address = _storage.read<String>(_keyAddress) ?? '151 Commercial Ave, Blue Area, Islamabad';
    final phone = _storage.read<String>(_keyPhone) ?? 'Tel: +92 51 8899000';
    final taxNumber = _storage.read<String>(_keyTaxNumber) ?? 'VAT Reg TIN: 000-887-213-0000';
    final minNumber = _storage.read<String>(_keyMinNumber) ?? 'MIN: 123456789';
    final terminalId = _storage.read<String>(_keyTerminalId) ?? 'POS #01';
    final footer = _storage.read<String>(_keyFooterMessage) ?? 'THIS IS YOUR OFFICIAL RECEIPT\nTHANK YOU, PLEASE COME AGAIN!';
    final vat = (_storage.read(_keyVatRate) as num?)?.toDouble() ?? 16.0;

    settings.value = ReceiptSettings(
      storeName: storeName,
      branchName: branchName,
      address: address,
      phone: phone,
      taxNumber: taxNumber,
      minNumber: minNumber,
      terminalId: terminalId,
      footerMessage: footer,
      vatRate: vat,
    );
  }

  Future<void> saveSettings({
    required String storeName,
    required String branchName,
    required String address,
    required String phone,
    required String taxNumber,
    required String minNumber,
    required String terminalId,
    required String footerMessage,
    required double vatRate,
  }) async {
    await _storage.write(_keyStoreName, storeName);
    await _storage.write(_keyBranchName, branchName);
    await _storage.write(_keyAddress, address);
    await _storage.write(_keyPhone, phone);
    await _storage.write(_keyTaxNumber, taxNumber);
    await _storage.write(_keyMinNumber, minNumber);
    await _storage.write(_keyTerminalId, terminalId);
    await _storage.write(_keyFooterMessage, footerMessage);
    await _storage.write(_keyVatRate, vatRate);

    settings.value = ReceiptSettings(
      storeName: storeName,
      branchName: branchName,
      address: address,
      phone: phone,
      taxNumber: taxNumber,
      minNumber: minNumber,
      terminalId: terminalId,
      footerMessage: footerMessage,
      vatRate: vatRate,
    );
  }
}
