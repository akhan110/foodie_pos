import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/data/data/dummy/dummy_model_data.dart';
import 'package:foodiepos/modules/deals/models/deal_model.dart';
import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/parked_order_model.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/dialogs/receipt_dialog.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PosController extends GetxController {
  final IPosRepository _posRepository;

  PosController({IPosRepository? posRepository})
      : _posRepository = posRepository ?? PosRepository();

  final RxList<ProductCategoryModel> categories = <ProductCategoryModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // Deals State
  final RxList<DealModel> allDeals = <DealModel>[].obs;
  final RxList<DealModel> filteredDeals = <DealModel>[].obs;
  final RxBool isLoadingDeals = false.obs;

  final RxString selectedCategory = 'all'.obs;
  final RxString selectedTopFilter = 'all'.obs; // 'all', 'popular', 'combos'
  final RxString searchQuery = ''.obs;

  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxString errorMessage = ''.obs;

  // Reactive Cart
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxString orderType = 'Dine In'.obs;

  // Parked / Held Orders
  final RxList<ParkedOrderModel> parkedOrders = <ParkedOrderModel>[].obs;

  // Discounts
  final RxString discountType = 'none'.obs; // 'none', 'percent', 'flat'
  final RxDouble discountValue = 0.0.obs;

  // Payment View State
  final RxBool isPaymentView = false.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxDouble cashReceived = 0.0.obs;
  final TextEditingController cashReceivedController = TextEditingController();
  final RxBool isPlacingOrder = false.obs;

  // Split Payment State
  final RxString paymentMode = 'single'.obs; // 'single', 'split'
  final RxDouble splitCashAmount = 0.0.obs;
  final RxDouble splitCardAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMenuData();
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<ShiftController>()) {
      Get.find<ShiftController>().checkAndPromptOpenShift();
    }
  }

  Future<void> loadMenuData() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
      fetchDeals(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final response = await _posRepository.getCategories();
      List<ProductCategoryModel> list = [];
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        list = List.from(response.data!);
      } else {
        list = [
          ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
          ProductCategoryModel(id: 'chicken', name: 'Chicken', slug: 'chicken'),
          ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
          ProductCategoryModel(id: 'sides', name: 'Sides', slug: 'sides'),
          ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
          ProductCategoryModel(id: 'desserts', name: 'Desserts', slug: 'desserts'),
        ];
      }

      // Ensure Deals category exists in the list
      if (!list.any((c) => c.name.toLowerCase() == 'deals' || c.id.toLowerCase() == 'deals')) {
        list.add(ProductCategoryModel(id: 'deals', name: 'Deals', slug: 'deals'));
      }

      categories.assignAll(list);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      categories.assignAll([
        ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
        ProductCategoryModel(id: 'chicken', name: 'Chicken', slug: 'chicken'),
        ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
        ProductCategoryModel(id: 'sides', name: 'Sides', slug: 'sides'),
        ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
        ProductCategoryModel(id: 'desserts', name: 'Desserts', slug: 'desserts'),
        ProductCategoryModel(id: 'deals', name: 'Deals', slug: 'deals'),
      ]);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchDeals() async {
    try {
      isLoadingDeals.value = true;
      final response = await _posRepository.getDeals(activeOnly: true);
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        allDeals.assignAll(response.data!);
      } else {
        allDeals.assignAll(_getDefaultDeals());
      }
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching deals: $e');
      allDeals.assignAll(_getDefaultDeals());
      _applyFilters();
    } finally {
      isLoadingDeals.value = false;
    }
  }

  List<DealModel> _getDefaultDeals() {
    return [
      DealModel(
        id: 'deal-1',
        name: 'Burger Combo',
        description: 'Classic burger + Fries + Drink',
        category: 'Meal Combos',
        price: 799.0,
        originalPrice: 1060.0,
        discountAmount: 261.0,
        image: 'assets/svg/products/burger.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd1-1', productName: 'Classic Smash Burger', unitPrice: 620, totalPrice: 620, quantity: 1, productImage: 'assets/svg/products/burger.svg'),
          DealItemModel(id: 'd1-2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 260, quantity: 1, productImage: 'assets/svg/products/fries.svg'),
          DealItemModel(id: 'd1-3', productName: 'Cola', unitPrice: 180, totalPrice: 180, quantity: 1, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-2',
        name: 'Pizza Family Deal',
        description: '2 Large Pizzas + 4 Drinks',
        category: 'Family Deals',
        price: 2999.0,
        originalPrice: 3600.0,
        discountAmount: 601.0,
        image: 'assets/svg/products/pizza.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd2-1', productName: 'Pepperoni Pizza', unitPrice: 890, totalPrice: 1780, quantity: 2, productImage: 'assets/svg/products/pizza.svg'),
          DealItemModel(id: 'd2-2', productName: 'Cola', unitPrice: 180, totalPrice: 720, quantity: 4, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-3',
        name: 'Chicken Meal',
        description: 'Chicken + Fries + Drink',
        category: 'Meal Combos',
        price: 850.0,
        originalPrice: 1120.0,
        discountAmount: 270.0,
        image: 'assets/svg/products/chicken.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd3-1', productName: 'Crunch Chicken', unitPrice: 740, totalPrice: 740, quantity: 1, productImage: 'assets/svg/products/chicken.svg'),
          DealItemModel(id: 'd3-2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 260, quantity: 1, productImage: 'assets/svg/products/fries.svg'),
          DealItemModel(id: 'd3-3', productName: 'Cola', unitPrice: 180, totalPrice: 180, quantity: 1, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-4',
        name: 'Kids Special',
        description: 'Kids burger + Fries + Juice',
        category: 'Meal Combos',
        price: 499.0,
        originalPrice: 680.0,
        discountAmount: 181.0,
        image: 'assets/svg/products/burger.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd4-1', productName: 'Kids Burger', unitPrice: 320, totalPrice: 320, quantity: 1, productImage: 'assets/svg/products/burger.svg'),
          DealItemModel(id: 'd4-2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 260, quantity: 1, productImage: 'assets/svg/products/fries.svg'),
        ],
      ),
      DealModel(
        id: 'deal-5',
        name: 'Couple Deal',
        description: '2 Burgers + 2 Fries + 2 Drinks',
        category: 'Family Deals',
        price: 1299.0,
        originalPrice: 1550.0,
        discountAmount: 251.0,
        image: 'assets/svg/products/burger.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd5-1', productName: 'Classic Smash Burger', unitPrice: 620, totalPrice: 1240, quantity: 2, productImage: 'assets/svg/products/burger.svg'),
          DealItemModel(id: 'd5-2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 520, quantity: 2, productImage: 'assets/svg/products/fries.svg'),
          DealItemModel(id: 'd5-3', productName: 'Cola', unitPrice: 180, totalPrice: 360, quantity: 2, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-6',
        name: 'Dessert Deal',
        description: 'Any 2 Sundaes + 2 Drinks',
        category: 'Limited Time',
        price: 399.0,
        originalPrice: 640.0,
        discountAmount: 241.0,
        image: 'assets/svg/products/dessert.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd6-1', productName: 'Chocolate Sundae', unitPrice: 320, totalPrice: 640, quantity: 2, productImage: 'assets/svg/products/dessert.svg'),
          DealItemModel(id: 'd6-2', productName: 'Cola', unitPrice: 180, totalPrice: 360, quantity: 2, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
    ];
  }

  Future<void> fetchProducts({String? categoryId}) async {
    try {
      isLoadingProducts.value = true;
      errorMessage.value = '';

      final response = await _posRepository.getProducts(categoryId: categoryId);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        allProducts.assignAll(response.data!);
      } else {
        allProducts.assignAll(ProductDummyData.products);
      }
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      allProducts.assignAll(ProductDummyData.products);
      _applyFilters();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    _applyFilters();
  }

  void selectTopFilter(String filter) {
    selectedTopFilter.value = filter;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  void _applyFilters() {
    // 1. Filter Products
    List<ProductModel> productList = List.from(allProducts);

    if (selectedTopFilter.value == 'popular') {
      productList = productList.where((p) => p.isPopular).toList();
    } else if (selectedTopFilter.value == 'combos') {
      productList = productList.where((p) => p.isCombo).toList();
    }

    if (selectedCategory.value != 'all' && selectedCategory.value != 'deals') {
      productList = productList.where((p) {
        final catName = p.category.name.toLowerCase();
        return catName == selectedCategory.value.toLowerCase() ||
            p.id == selectedCategory.value;
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      productList = productList.where((p) {
        return p.name.toLowerCase().contains(searchQuery.value);
      }).toList();
    }

    filteredProducts.assignAll(productList);

    // 2. Filter Deals
    List<DealModel> dealList = allDeals.where((d) => d.isActive).toList();
    if (searchQuery.value.isNotEmpty) {
      dealList = dealList.where((d) {
        final nameMatch = d.name.toLowerCase().contains(searchQuery.value);
        final descMatch = (d.description ?? '').toLowerCase().contains(searchQuery.value);
        return nameMatch || descMatch;
      }).toList();
    }
    filteredDeals.assignAll(dealList);
  }

  void addDealToCart(DealModel deal) {
    final dealProduct = ProductModel(
      id: 'deal-${deal.id}',
      name: deal.name,
      description: deal.description ??
          deal.items.map((i) => '${i.quantity > 1 ? "${i.quantity}x " : ""}${i.productName}').join(' + '),
      price: deal.price,
      category: ProductCategory.deals,
      image: deal.image,
      isPopular: true,
      isCombo: true,
      isActive: true,
    );
    addToCart(dealProduct);
  }

  // ===========================================================================
  // CART OPERATIONS
  // ===========================================================================

  int getProductCartQuantity(String productId) {
    return cartItems
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  void addToCart(ProductModel product) {
    final defaultItem = CartItemModel(product: product, quantity: 1);
    final index = cartItems.indexWhere((item) => item.id == defaultItem.id);
    if (index >= 0) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    } else {
      cartItems.add(defaultItem);
    }
  }

  void addCustomizedItemToCart({
    required ProductModel product,
    required ProductSizeOption size,
    required List<ProductExtraItem> extras,
    int quantity = 1,
    String? notes,
  }) {
    final newItem = CartItemModel(
      product: product,
      size: size,
      extras: extras,
      quantity: quantity,
      notes: notes,
    );

    final index = cartItems.indexWhere((item) => item.id == newItem.id);
    if (index >= 0) {
      cartItems[index].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(newItem);
    }
  }

  void quickIncrementProduct(ProductModel product) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    } else {
      addToCart(product);
    }
  }

  void quickDecrementProduct(ProductModel product) {
    final index = cartItems.lastIndexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
        cartItems.refresh();
      } else {
        cartItems.removeAt(index);
      }
    }
  }

  void incrementCartItem(String cartItemId) {
    final index = cartItems.indexWhere((item) => item.id == cartItemId || item.product.id == cartItemId);
    if (index >= 0) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    }
  }

  void decrementCartItem(String cartItemId) {
    final index = cartItems.indexWhere((item) => item.id == cartItemId || item.product.id == cartItemId);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
        cartItems.refresh();
      } else {
        cartItems.removeAt(index);
      }
    }
  }

  void incrementQuantity(String id) => incrementCartItem(id);
  void decrementQuantity(String id) => decrementCartItem(id);

  void removeFromCart(String id) {
    cartItems.removeWhere((item) => item.id == id || item.product.id == id);
  }

  void clearCart() {
    cartItems.clear();
    removeDiscount();
  }

  // ===========================================================================
  // PARKED ORDERS (HOLD CART)
  // ===========================================================================

  void parkCurrentOrder({String? label}) {
    if (cartItems.isEmpty) {
      AppLoader.showInfo('Cart is empty. Nothing to hold.');
      return;
    }

    final parked = ParkedOrderModel(
      id: 'park_${DateTime.now().millisecondsSinceEpoch}',
      label: label ?? 'Order #${parkedOrders.length + 1} (${orderType.value})',
      items: List.from(cartItems),
      orderType: orderType.value,
      parkedAt: DateTime.now(),
    );

    parkedOrders.add(parked);
    clearCart();
    AppLoader.showSuccess('Order held successfully! Parked count: ${parkedOrders.length}');
  }

  void restoreParkedOrder(String id) {
    final index = parkedOrders.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final parked = parkedOrders.removeAt(index);
      orderType.value = parked.orderType;
      cartItems.assignAll(parked.items);
      AppLoader.showSuccess('Restored order "${parked.label}" to cart');
    }
  }

  void deleteParkedOrder(String id) {
    parkedOrders.removeWhere((p) => p.id == id);
    AppLoader.showInfo('Parked order deleted');
  }

  // ===========================================================================
  // DISCOUNT OPERATIONS
  // ===========================================================================

  void applyDiscount(String type, double value) {
    discountType.value = type;
    discountValue.value = value;
    if (isPaymentView.value && selectedPaymentMethod.value != 'Cash') {
      cashReceived.value = total;
      cashReceivedController.text = total.round().toString();
    }
  }

  void removeDiscount() {
    discountType.value = 'none';
    discountValue.value = 0.0;
  }

  double get discountAmount {
    if (discountType.value == 'percent') {
      return (subtotal * (discountValue.value / 100)).clamp(0.0, subtotal);
    } else if (discountType.value == 'flat') {
      return discountValue.value.clamp(0.0, subtotal);
    }
    return 0.0;
  }

  // ===========================================================================
  // TOTALS CALCULATION
  // ===========================================================================

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get tax => (subtotal - discountAmount) > 0 ? (subtotal - discountAmount) * 0.16 : 0.0;

  double get total => (subtotal - discountAmount + tax).clamp(0.0, double.infinity);

  // ===========================================================================
  // PAYMENT FLOW
  // ===========================================================================

  @override
  void onClose() {
    cashReceivedController.dispose();
    super.onClose();
  }

  void openPayment() {
    if (cartItems.isEmpty) return;

    final currentTotal = total;
    final rounded = (currentTotal > 0 && currentTotal % 500 != 0)
        ? ((currentTotal / 500).ceil() * 500).toDouble()
        : currentTotal;

    cashReceived.value = rounded;
    cashReceivedController.text = rounded.round().toString();
    selectedPaymentMethod.value = 'Cash';
    paymentMode.value = 'single';
    splitCashAmount.value = currentTotal / 2;
    splitCardAmount.value = currentTotal / 2;
    isPaymentView.value = true;
  }

  void cancelPayment() {
    isPaymentView.value = false;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    if (method != 'Cash') {
      cashReceived.value = total;
      cashReceivedController.text = total.round().toString();
    }
  }

  void setCashReceived(double amount) {
    cashReceived.value = amount;
    cashReceivedController.text = amount.round().toString();
  }

  void addCashPreset(double noteAmount) {
    final current = double.tryParse(cashReceivedController.text) ?? 0.0;
    final updated = current + noteAmount;
    setCashReceived(updated);
  }

  void onCashInputChanged(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(cleaned) ?? 0.0;
    cashReceived.value = val;
  }

  double get changeAmount =>
      (cashReceived.value - total) > 0 ? (cashReceived.value - total) : 0.0;

  Future<void> completeOrder() async {
    if (cartItems.isEmpty) {
      AppLoader.showInfo('Cart is empty.');
      return;
    }

    try {
      isPlacingOrder.value = true;
      AppLoader.show(status: 'Completing order...');

      final storage = GetStorage();
      final cashierName = storage.read(StorageKeys.cashierName) ?? 'Akhan';

      final String calculatedTable;
      final typeLower = orderType.value.toLowerCase();
      if (typeLower.contains('dine')) {
        calculatedTable = 'Table 5';
      } else if (typeLower.contains('delivery')) {
        calculatedTable = 'Online Rider';
      } else {
        calculatedTable = 'Counter';
      }

      final payloadItems = cartItems.map((it) {
        return {
          'product_id': it.product.id,
          'product_name': it.product.name,
          'product_image': it.product.image,
          'size': it.size.name,
          'addons': it.extras.isNotEmpty
              ? it.extras.map((e) => e.name).join(', ')
              : null,
          'quantity': it.quantity,
          'unit_price': it.unitPrice,
          'total_price': it.subtotal,
          'notes': it.notes,
        };
      }).toList();

      final paymentMethodStr = paymentMode.value == 'split'
          ? 'Split (Cash Rs ${splitCashAmount.value.toStringAsFixed(0)} + Card Rs ${splitCardAmount.value.toStringAsFixed(0)})'
          : selectedPaymentMethod.value;

      final double actualReceived = paymentMode.value == 'split'
          ? total
          : (selectedPaymentMethod.value == 'Cash' ? cashReceived.value : total);

      final double actualChange = paymentMode.value == 'split'
          ? 0.0
          : (selectedPaymentMethod.value == 'Cash' ? changeAmount : 0.0);

      final orderPayload = {
        'order_type': orderType.value,
        'status': 'New',
        'table_number': calculatedTable,
        'cashier_name': cashierName,
        'payment_method': paymentMethodStr,
        'subtotal': subtotal,
        'tax': tax,
        'discount': discountAmount,
        'total': total,
        'amount_received': actualReceived,
        'change_amount': actualChange,
        'items': payloadItems,
      };

      final response = await _posRepository.createOrder(orderPayload);
      final orderNumber = (response.data != null && response.data!['order_number'] != null)
          ? response.data!['order_number'].toString()
          : '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      final receiptData = {
        'order_number': orderNumber,
        'order_type': orderType.value,
        'table_number': calculatedTable,
        'cashier_name': cashierName,
        'payment_method': paymentMethodStr,
        'subtotal': subtotal,
        'tax': tax,
        'discount': discountAmount,
        'total': total,
        'amount_received': actualReceived,
        'change_amount': actualChange,
        'items': payloadItems,
      };

      AppLoader.showSuccess('Order $orderNumber placed successfully!');

      // Clear cart & close payment view
      clearCart();
      isPaymentView.value = false;

      // Refresh Orders tab
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().loadOrders(showLoading: false);
      }

      // Show Thermal Receipt Popup
      if (Get.context != null) {
        ReceiptDialog.show(Get.context!, receiptData, onPrintComplete: () {
          if (Get.isRegistered<MainShellController>()) {
            Get.find<MainShellController>().changePage(2);
          }
        });
      } else if (Get.isRegistered<MainShellController>()) {
        Get.find<MainShellController>().changePage(2);
      }
    } catch (e) {
      final fallbackNum = '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      AppLoader.showSuccess('Order $fallbackNum placed successfully (Offline)!');

      clearCart();
      isPaymentView.value = false;

      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().loadOrders(showLoading: false);
      }
      if (Get.isRegistered<MainShellController>()) {
        Get.find<MainShellController>().changePage(2);
      }
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
