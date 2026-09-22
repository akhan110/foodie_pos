import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
import 'package:get/get.dart';

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
  Future<BaseResponseModel<List<ProductModel>>> getProducts({String? categoryId}) async {
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

  group('PosController & Products API Tests', () {
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
  });
}
