import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/menu/controllers/menu_management_controller.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MockPosRepository implements IPosRepository {
  @override
  Future<BaseResponseModel<List<ProductCategoryModel>>> getCategories() async {
    return BaseResponseModel(
      success: true,
      message: 'Categories retrieved',
      statusCode: 200,
      data: [
        ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
        ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
        ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
      ],
    );
  }

  @override
  Future<BaseResponseModel<List<ProductModel>>> getProducts({
    String? categoryId,
    bool includeInactive = false,
  }) async {
    final list = [
      const ProductModel(
        id: '1',
        name: 'Classic Smash Burger',
        category: ProductCategory.burgers,
        price: 620,
        image: 'assets/svg/products/burger.svg',
        isPopular: true,
      ),
      const ProductModel(
        id: '2',
        name: 'Pepperoni Pizza',
        category: ProductCategory.pizza,
        price: 890,
        image: 'assets/svg/products/pizza.svg',
        isPopular: true,
      ),
      const ProductModel(
        id: '3',
        name: 'Cola',
        category: ProductCategory.drinks,
        price: 180,
        image: 'assets/svg/products/drink.svg',
        isPopular: false,
        isCombo: true,
      ),
    ];

    if (categoryId != null && categoryId != 'all') {
      return BaseResponseModel(
        success: true,
        message: 'Products retrieved',
        statusCode: 200,
        data: list.where((p) => p.category.name == categoryId).toList(),
      );
    }

    return BaseResponseModel(
      success: true,
      message: 'Products retrieved',
      statusCode: 200,
      data: list,
    );
  }

  @override
  Future<BaseResponseModel<List<ProductExtraItem>>> getAddons({String? categoryId}) async {
    return BaseResponseModel(
      success: true,
      message: 'Addons retrieved',
      statusCode: 200,
      data: [
        const ProductExtraItem(id: 'cheese', name: 'Extra cheese', price: 90),
        const ProductExtraItem(id: 'jalapenos', name: 'Jalapeños', price: 60),
      ],
    );
  }

  @override
  Future<BaseResponseModel<List<ProductSizeOption>>> getSizeOptions({String? categoryId}) async {
    return BaseResponseModel(
      success: true,
      message: 'Sizes retrieved',
      statusCode: 200,
      data: [
        const ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0),
        const ProductSizeOption(id: 'large', name: 'Large', extraPrice: 120),
      ],
    );
  }

  @override
  Future<BaseResponseModel<ProductModel>> createProduct(Map<String, dynamic> data) async {
    final prod = ProductModel.fromJson({...data, 'id': 'prod-new'});
    return BaseResponseModel(
      success: true,
      message: 'Product created',
      statusCode: 201,
      data: prod,
    );
  }

  @override
  Future<BaseResponseModel<ProductModel>> updateProduct(String id, Map<String, dynamic> data) async {
    final prod = ProductModel.fromJson({...data, 'id': id});
    return BaseResponseModel(
      success: true,
      message: 'Product updated',
      statusCode: 200,
      data: prod,
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> deleteProduct(String id) async {
    return BaseResponseModel(
      success: true,
      message: 'Product deleted',
      statusCode: 200,
      data: {'id': id},
    );
  }

  @override
  Future<BaseResponseModel<ProductExtraItem>> createAddon(Map<String, dynamic> data) async {
    return BaseResponseModel(
      success: true,
      message: 'Addon created',
      statusCode: 201,
      data: ProductExtraItem(
        id: 'add-new',
        name: data['name']?.toString() ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  @override
  Future<BaseResponseModel<ProductExtraItem>> updateAddon(String id, Map<String, dynamic> data) async {
    return BaseResponseModel(
      success: true,
      message: 'Addon updated',
      statusCode: 200,
      data: ProductExtraItem(
        id: id,
        name: data['name']?.toString() ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> deleteAddon(String id) async {
    return BaseResponseModel(
      success: true,
      message: 'Addon deleted',
      statusCode: 200,
      data: {'id': id},
    );
  }

  @override
  Future<BaseResponseModel<ProductSizeOption>> createSizeOption(Map<String, dynamic> data) async {
    return BaseResponseModel(
      success: true,
      message: 'Size created',
      statusCode: 201,
      data: ProductSizeOption(
        id: 'sz-new',
        name: data['name']?.toString() ?? '',
        extraPrice: (data['extra_price'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  @override
  Future<BaseResponseModel<dynamic>> deleteSizeOption(String id) async {
    return BaseResponseModel(
      success: true,
      message: 'Size deleted',
      statusCode: 200,
      data: {'id': id},
    );
  }

  @override
  Future<BaseResponseModel<String>> uploadImage(
    String filePath, {
    List<int>? bytes,
    String? filename,
  }) async {
    return BaseResponseModel(
      success: true,
      message: 'Image uploaded',
      statusCode: 200,
      data: '/uploads/mock_uploaded_img.png',
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> createOrder(Map<String, dynamic> orderPayload) async {
    return BaseResponseModel(
      success: true,
      message: 'Order created',
      statusCode: 201,
      data: {'order_id': 'ord-1234'},
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

  group('PosController & Products Customization & Cart Tests', () {
    late MockPosRepository mockRepo;
    late PosController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockPosRepository();
      controller = PosController(posRepository: mockRepo);
    });

    test('1. Loads categories and products on init', () async {
      await controller.loadMenuData();

      expect(controller.categories.length, 3);
      expect(controller.allProducts.length, 3);
      expect(controller.filteredProducts.length, 3);
    });

    test('2. Filters products by category and search', () async {
      await controller.loadMenuData();

      // Filter by burgers
      controller.selectCategory('burgers');
      expect(controller.filteredProducts.length, 1);
      expect(controller.filteredProducts.first.name, 'Classic Smash Burger');

      // Filter by all
      controller.selectCategory('all');
      expect(controller.filteredProducts.length, 3);

      // Search
      controller.onSearchChanged('Cola');
      expect(controller.filteredProducts.length, 1);
      expect(controller.filteredProducts.first.name, 'Cola');
    });

    test('3. Reactive Cart Add, Increment, Decrement, and Totals', () async {
      await controller.loadMenuData();

      final burger = controller.allProducts.first;

      // Add to cart
      controller.addToCart(burger);
      expect(controller.cartItems.length, 1);
      expect(controller.cartItems.first.quantity, 1);
      expect(controller.subtotal, 620.0);
      expect(controller.tax, 620.0 * 0.16);

      // Increment
      controller.incrementQuantity(burger.id);
      expect(controller.cartItems.first.quantity, 2);
      expect(controller.subtotal, 1240.0);

      // Decrement
      controller.decrementQuantity(burger.id);
      expect(controller.cartItems.first.quantity, 1);

      // Clear
      controller.clearCart();
      expect(controller.cartItems.isEmpty, isTrue);
    });

    test('4. Customized Item with Size and Extras computation', () async {
      await controller.loadMenuData();

      final burger = controller.allProducts.first; // 620

      // Add customized: Large (+120), Extra cheese (+90), qty 2
      controller.addCustomizedItemToCart(
        product: burger,
        size: const ProductSizeOption(id: 'large', name: 'Large', extraPrice: 120),
        extras: const [
          ProductExtraItem(id: 'cheese', name: 'Extra cheese', price: 90),
        ],
        quantity: 2,
      );

      expect(controller.cartItems.length, 1);
      final item = controller.cartItems.first;
      // unitPrice = 620 + 120 + 90 = 830. Subtotal = 830 * 2 = 1660
      expect(item.unitPrice, 830.0);
      expect(item.subtotal, 1660.0);
      expect(item.subtitle, 'Large · Extra cheese');
      expect(controller.subtotal, 1660.0);
    });

    test('5. Direct Card Stepper controls and getProductCartQuantity', () async {
      await controller.loadMenuData();

      final burger = controller.allProducts.first;

      expect(controller.getProductCartQuantity(burger.id), 0);

      // Quick Increment from product card button
      controller.quickIncrementProduct(burger);
      expect(controller.getProductCartQuantity(burger.id), 1);

      controller.quickIncrementProduct(burger);
      expect(controller.getProductCartQuantity(burger.id), 2);

      // Quick Decrement from product card button
      controller.quickDecrementProduct(burger);
      expect(controller.getProductCartQuantity(burger.id), 1);

      controller.quickDecrementProduct(burger);
      expect(controller.getProductCartQuantity(burger.id), 0);
      expect(controller.cartItems.isEmpty, true);
    });

    test('6. Payment flow open, method select, cash calculation, and complete order', () async {
      await controller.loadMenuData();
      final prod = controller.allProducts.first;
      controller.addToCart(prod);
      controller.addToCart(prod);

      expect(controller.cartItems.isNotEmpty, true);
      expect(controller.isPaymentView.value, false);

      controller.openPayment();
      expect(controller.isPaymentView.value, true);
      expect(controller.selectedPaymentMethod.value, 'Cash');
      expect(controller.cashReceived.value >= controller.total, true);

      controller.selectPaymentMethod('Card');
      expect(controller.selectedPaymentMethod.value, 'Card');
      expect(controller.cashReceived.value, controller.total);

      controller.selectPaymentMethod('Cash');
      controller.setCashReceived(controller.total + 140);
      expect(controller.changeAmount, 140.0);

      await controller.completeOrder();
      expect(controller.cartItems.isEmpty, true);
      expect(controller.isPaymentView.value, false);
    });
  });

  group('MenuManagementController Tests', () {
    late MockPosRepository mockRepo;
    late MenuManagementController menuController;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockPosRepository();
      menuController = MenuManagementController(repository: mockRepo);
    });

    test('1. Loads menu products and selects first product', () async {
      await menuController.loadMenu();

      expect(menuController.products.length, 3);
      expect(menuController.selectedProduct.value, isNotNull);
      expect(menuController.selectedProduct.value!.name, 'Classic Smash Burger');
      expect(menuController.nameController.text, 'Classic Smash Burger');
    });

    test('2. Filters products by category count', () async {
      await menuController.loadMenu();

      expect(menuController.getCategoryCount('all'), 3);
      expect(menuController.getCategoryCount('burgers'), 1);
      expect(menuController.getCategoryCount('pizza'), 1);
      expect(menuController.getCategoryCount('drinks'), 1);
    });

    test('3. Starts new product and creates it', () async {
      await menuController.loadMenu();

      menuController.startNewProduct();
      expect(menuController.isCreatingNew.value, isTrue);
      expect(menuController.selectedProduct.value, isNull);
      expect(menuController.nameController.text, isEmpty);

      menuController.nameController.text = 'Double Bacon Burger';
      menuController.priceController.text = '750';
      menuController.formCategory.value = 'burgers';

      await menuController.saveProduct();

      expect(menuController.products.first.name, 'Double Bacon Burger');
      expect(menuController.isCreatingNew.value, isFalse);
    });

    test('4. Deletes product', () async {
      await menuController.loadMenu();

      final countBefore = menuController.products.length;
      final target = menuController.products.first;

      await menuController.deleteProduct(target.id);
      expect(menuController.products.length, countBefore - 1);
    });

    test('5. Adds and deletes custom size options for a category', () async {
      await menuController.loadMenu();
      await menuController.fetchSizesForCategory('burgers');

      expect(menuController.currentSizes.length, 2);
      expect(menuController.currentSizes.first.name, 'Regular');

      // Add XL Size
      await menuController.addNewSizeOption('XL', 220);
      expect(menuController.currentSizes.length, 3);
      expect(menuController.currentSizes.last.name, 'XL');
      expect(menuController.currentSizes.last.extraPrice, 220);

      // Remove Size
      await menuController.removeSizeOption('sz-new');
      expect(menuController.currentSizes.length, 2);
    });

    test('6. Image upload repository returns valid uploaded URL', () async {
      final res = await mockRepo.uploadImage('test_path.png');
      expect(res.success, isTrue);
      expect(res.data, '/uploads/mock_uploaded_img.png');
    });
  });
}
