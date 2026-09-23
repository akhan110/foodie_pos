import 'dart:typed_data';
import 'package:foodiepos/services/receipt_settings_service.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ThermalPrinterService {
  ThermalPrinterService._();

  static ReceiptSettings get _settings {
    if (Get.isRegistered<ReceiptSettingsService>()) {
      return Get.find<ReceiptSettingsService>().settings.value;
    }
    return const ReceiptSettings(
      storeName: 'BITEFLOW FAST FOOD',
      branchName: 'Store #01 • Main Branch',
      address: '151 Commercial Ave, Blue Area, Islamabad',
      phone: 'Tel: +92 51 8899000',
      taxNumber: 'VAT Reg TIN: 000-887-213-0000',
      minNumber: 'MIN: 123456789',
      terminalId: 'POS #01',
      footerMessage: 'THIS IS YOUR OFFICIAL RECEIPT\nTHANK YOU, PLEASE COME AGAIN!',
      vatRate: 16.0,
    );
  }

  static const _pageFormat = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginAll: 3 * PdfPageFormat.mm,
  );

  /// Generate 80mm standard customer thermal receipt PDF
  static Future<Uint8List> generateReceiptPdf(Map<String, dynamic> orderData) async {
    final pdf = pw.Document();
    pdf.addPage(_buildCustomerPage(orderData, _settings));
    return pdf.save();
  }

  /// Generate Kitchen Order Ticket (KOT) PDF
  static Future<Uint8List> generateKitchenTicketPdf(Map<String, dynamic> orderData) async {
    final pdf = pw.Document();
    pdf.addPage(_buildKitchenPage(orderData));
    return pdf.save();
  }

  /// Generate BOTH Customer Bill (Page 1) and Kitchen Ticket (Page 2) in 1 document
  static Future<Uint8List> generateBothPdf(Map<String, dynamic> orderData) async {
    final pdf = pw.Document();
    pdf.addPage(_buildCustomerPage(orderData, _settings));
    pdf.addPage(_buildKitchenPage(orderData));
    return pdf.save();
  }

  /// Print Customer Bill only
  static Future<void> printReceipt(Map<String, dynamic> orderData) async {
    final pdfBytes = await generateReceiptPdf(orderData);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Bill_${orderData['order_number'] ?? 'Order'}',
    );
  }

  /// Print Kitchen Order Ticket only
  static Future<void> printKitchenTicket(Map<String, dynamic> orderData) async {
    final pdfBytes = await generateKitchenTicketPdf(orderData);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'KOT_${orderData['order_number'] ?? 'Order'}',
    );
  }

  /// Print BOTH Customer Bill and Kitchen Ticket in one print job
  static Future<void> printBoth(Map<String, dynamic> orderData) async {
    final pdfBytes = await generateBothPdf(orderData);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Bill_and_KOT_${orderData['order_number'] ?? 'Order'}',
    );
  }

  // ===========================================================================
  // PAGE BUILDERS
  // ===========================================================================
  static pw.Page _buildCustomerPage(Map<String, dynamic> orderData, ReceiptSettings s) {
    final orderNumber = (orderData['order_number'] ?? '#1001').toString();
    final orderType = (orderData['order_type'] ?? 'Dine In').toString();
    final cashierName = (orderData['cashier_name'] ?? 'Akhan').toString();
    final items = (orderData['items'] as List?) ?? [];
    final subtotal = (orderData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final tax = (orderData['tax'] as num?)?.toDouble() ?? 0.0;
    final discount = (orderData['discount'] as num?)?.toDouble() ?? 0.0;
    final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod = (orderData['payment_method'] ?? 'Cash').toString();
    final amountReceived = (orderData['amount_received'] as num?)?.toDouble() ?? total;
    final changeAmount = (orderData['change_amount'] as num?)?.toDouble() ?? 0.0;
    final dateStr = DateTime.now().toString().substring(0, 19);

    final vatableSales = total > tax ? (total - tax) : subtotal;
    final totalItemsCount = items.fold<int>(
      0,
      (acc, item) => acc + ((item['quantity'] as num?)?.toInt() ?? 1),
    );

    return pw.Page(
      pageFormat: _pageFormat,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Store Header
            pw.Text(
              s.storeName.toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
            pw.SizedBox(height: 2),
            pw.Text(s.address, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
            pw.Text(s.phone, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
            pw.Text(s.taxNumber, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Text(s.minNumber, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),

            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.6, borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 2),

            // Transaction Meta
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(paymentMethod.toUpperCase() == 'CASH' ? 'CASH SALES' : '${paymentMethod.toUpperCase()} SALES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                pw.Text(orderType.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(s.terminalId, style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Cashier: $cashierName', style: const pw.TextStyle(fontSize: 8)),
              ],
            ),

            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.6, borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 2),

            // 4-Column Table Header
            pw.Row(
              children: [
                pw.Expanded(flex: 5, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5))),
                pw.SizedBox(width: 25, child: pw.Text('Qty', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5))),
                pw.SizedBox(width: 48, child: pw.Text('Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5))),
                pw.SizedBox(width: 55, child: pw.Text('Amount', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5))),
              ],
            ),

            pw.Divider(thickness: 0.4),

            // Item Lines
            ...items.map((item) {
              final name = (item['product_name'] ?? item['name'] ?? 'Item').toString();
              final qty = (item['quantity'] as num?)?.toInt() ?? 1;
              final unitPrice = (item['unit_price'] as num?)?.toDouble() ??
                  (((item['price'] as num?)?.toDouble() ?? 0.0) / (qty > 0 ? qty : 1));
              final lineTotal = (item['total_price'] as num?)?.toDouble() ??
                  ((item['price'] as num?)?.toDouble() ?? (unitPrice * qty));
              final sizeRaw = (item['size'] ?? item['selectedSize'] ?? 'Regular').toString().trim();
              final size = sizeRaw.isEmpty ? 'Regular' : sizeRaw;
              final addonsStr = _parseAddons(item['addons'] ?? item['selectedAddons'] ?? item['extras']);

              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(
                            name,
                            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                            maxLines: 2,
                          ),
                        ),
                        pw.SizedBox(
                          width: 25,
                          child: pw.Text(qty.toString(), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8.5)),
                        ),
                        pw.SizedBox(
                          width: 48,
                          child: pw.Text(unitPrice.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8.5)),
                        ),
                        pw.SizedBox(
                          width: 55,
                          child: pw.Text(lineTotal.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (size != 'Regular' || addonsStr != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 4, top: 1),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (size != 'Regular')
                              pw.Text('  Size: $size', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                            if (addonsStr != null)
                              pw.Text('  + $addonsStr', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 3),
            pw.Divider(thickness: 0.6, borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 2),

            // Summary & Payment
            _pwRow('TOTAL:', '$totalItemsCount Items', total.toStringAsFixed(2), isBold: true, fontSize: 10),
            if (discount > 0)
              _pwRow('Discount Applied', '', '- ${discount.toStringAsFixed(2)}', fontSize: 8.5),
            _pwRow('Payment Received', paymentMethod, amountReceived.toStringAsFixed(2), fontSize: 8.5),
            pw.Divider(thickness: 0.4),
            _pwRow('CHANGE', '', changeAmount.toStringAsFixed(2), isBold: true, fontSize: 9.5),

            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.6, borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),

            // Detailed Fiscal / VAT Breakdown
            _pwSimpleRow('VATable Sales', 'Rs ${vatableSales.toStringAsFixed(2)}'),
            _pwSimpleRow('Non-VAT Sales', 'Rs 0.00'),
            _pwSimpleRow('Zero-Rated Sales', 'Rs 0.00'),
            _pwSimpleRow('Total Sales', 'Rs ${subtotal.toStringAsFixed(2)}'),
            _pwSimpleRow('Total VAT (${s.vatRate.toStringAsFixed(0)}%)', 'Rs ${tax.toStringAsFixed(2)}'),
            _pwSimpleRow('Total Amount', 'Rs ${total.toStringAsFixed(2)}'),

            pw.SizedBox(height: 6),
            pw.Text('Trans No. ${orderNumber.replaceAll('#', '').padLeft(10, '0')}  $dateStr', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text('THIS IS YOUR OFFICIAL RECEIPT', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Text('FOR ORDERS & INQUIRIES\nTHANK YOU, PLEASE COME AGAIN!', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7.5)),

            pw.SizedBox(height: 6),

            // Customer Fields
            _pwCustomerLine('Customer:'),
            _pwCustomerLine('Address:'),
            _pwCustomerLine('TIN / NTN:'),
            _pwCustomerLine('Signature:'),

            pw.SizedBox(height: 6),

            // Barcode Widget (Code128)
            pw.Container(
              height: 26,
              width: 140,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: orderNumber,
                drawText: true,
                textStyle: const pw.TextStyle(fontSize: 7),
              ),
            ),

            pw.SizedBox(height: 4),
            pw.Text(
              'POS System Provider: BITEFLOW POS SOLUTIONS\nAccreditation: 0015-BF-2026-000500\nTHIS RECEIPT SHALL BE VALID FOR FISCAL RECORD',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
            ),
          ],
        );
      },
    );
  }

  static pw.Page _buildKitchenPage(Map<String, dynamic> orderData) {
    final orderNumber = (orderData['order_number'] ?? '#1001').toString();
    final orderType = (orderData['order_type'] ?? 'Dine In').toString();
    final tableNumber = (orderData['table_number'] ?? 'Counter').toString();
    final items = (orderData['items'] as List?) ?? [];
    final dateStr = DateTime.now().toString().substring(0, 19);

    return pw.Page(
      pageFormat: _pageFormat,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: const pw.BoxDecoration(color: PdfColors.black),
                child: pw.Text('*** KITCHEN ORDER TICKET ***', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('KOT: $orderNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                pw.Text(tableNumber.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              ],
            ),
            pw.Text('Type: $orderType | Time: $dateStr', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.Divider(thickness: 0.8),

            ...items.map((item) {
              final name = (item['product_name'] ?? item['name'] ?? 'Item').toString();
              final qty = (item['quantity'] as num?)?.toInt() ?? 1;
              final sizeRaw = (item['size'] ?? item['selectedSize'] ?? 'Regular').toString().trim();
              final size = sizeRaw.isEmpty ? 'Regular' : sizeRaw;
              final addonsStr = _parseAddons(item['addons'] ?? item['selectedAddons'] ?? item['extras']);
              final notesStr = _parseNotes(item['specialInstructions'] ?? item['notes'] ?? item['instructions']);

              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: const pw.BoxDecoration(color: PdfColors.black),
                          child: pw.Text('${qty}x', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        ),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          child: pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    if (size != 'Regular' || addonsStr != null || notesStr != null)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 20, top: 2),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (size != 'Regular')
                              pw.Text('• SIZE: ${size.toUpperCase()}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                            if (addonsStr != null)
                              pw.Text('• ADDONS: + $addonsStr', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                            if (notesStr != null)
                              pw.Text('• NOTE: "$notesStr"', style: pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic)),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.8),
            pw.Center(
              child: pw.Text('--- END OF KITCHEN TICKET ---', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ),
          ],
        );
      },
    );
  }

  // Parsers & Helpers
  static String? _parseAddons(dynamic rawAddons) {
    if (rawAddons == null) return null;
    if (rawAddons is String) {
      final trimmed = rawAddons.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null' || trimmed.toLowerCase() == 'none') {
        return null;
      }
      return trimmed;
    }
    if (rawAddons is Iterable) {
      final list = <String>[];
      for (final e in rawAddons) {
        if (e == null) continue;
        if (e is String) {
          final s = e.trim();
          if (s.isNotEmpty && s.toLowerCase() != 'null' && s.toLowerCase() != 'none') list.add(s);
        } else if (e is Map) {
          final name = (e['name'] ?? e['title'] ?? '').toString().trim();
          if (name.isNotEmpty && name.toLowerCase() != 'null') list.add(name);
        } else {
          try {
            final dynamic d = e;
            final name = (d.name as String?)?.trim();
            if (name != null && name.isNotEmpty) list.add(name);
          } catch (_) {
            final s = e.toString().trim();
            if (s.isNotEmpty && s.toLowerCase() != 'null') list.add(s);
          }
        }
      }
      if (list.isEmpty) return null;
      return list.join(', ');
    }
    return rawAddons.toString();
  }

  static String? _parseNotes(dynamic rawNotes) {
    if (rawNotes == null) return null;
    final str = rawNotes.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'none') {
      return null;
    }
    return str;
  }

  static pw.Widget _pwRow(String label, String middle, String amount, {bool isBold = false, double fontSize = 8.5}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize)),
          if (middle.isNotEmpty)
            pw.Text(middle, style: pw.TextStyle(fontSize: fontSize - 1, color: PdfColors.grey700)),
          pw.Text(amount, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize)),
        ],
      ),
    );
  }

  static pw.Widget _pwSimpleRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _pwCustomerLine(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 55, child: pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Container(height: 0.5, color: PdfColors.grey400)),
        ],
      ),
    );
  }
}
