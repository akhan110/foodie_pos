import 'package:flutter/foundation.dart';
import 'package:foodiepos/data/data/dummy/dummy_model_data.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
import 'package:get/get.dart';

class PosController extends GetxController {
  final IPosRepository _posRepository;

  PosController({IPosRepository? posRepository})
      : _posRepository = posRepository ?? PosRepository();

  final RxList<ProductCategoryModel> categories = <ProductCategoryModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  final RxString selectedCategory = 'all'.obs;
  final RxString selectedTopFilter = 'all'.obs; // 'all', 'popular', 'combos'
  final RxString searchQuery = ''.obs;

  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxString errorMessage = ''.obs;

  // Reactive Cart
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxString orderType = 'Dine In'.obs;

  @override
  void onInit() {
    super.onInit();
    loadMenuData();
  }

  Future<void> loadMenuData() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final response = await _posRepository.getCategories();
      if (response.success && response.data != null && response.data!.isNotEmpty) {
        categories.assignAll(response.data!);
      } else {
        // Fallback default categories
        categories.assignAll([
          ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
          ProductCategoryModel(id: 'chicken', name: 'Chicken', slug: 'chicken'),
          ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
          ProductCategoryModel(id: 'sides', name: 'Sides', slug: 'sides'),
          ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
          ProductCategoryModel(id: 'desserts', name: 'Desserts', slug: 'desserts'),
        ]);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      categories.assignAll([
        ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
        ProductCategoryModel(id: 'chicken', name: 'Chicken', slug: 'chicken'),
        ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
        ProductCategoryModel(id: 'sides', name: 'Sides', slug: 'sides'),
        ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
        ProductCategoryModel(id: 'desserts', name: 'Desserts', slug: 'desserts'),
      ]);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts({String? categoryId}) async {
    try {
      isLoadingProducts.value = true;
      errorMessage.value = '';

      final response = await _posRepository.getProducts(categoryId: categoryId);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        allProducts.assignAll(response.data!);
      } else {
        // Fallback to local catalog if API is offline
        allProducts.assignAll(ProductDummyData.products);
      }
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      // Offline fallback
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
    List<ProductModel> list = List.from(allProducts);

    // 1. Top filter (All / Popular / Combos)
    if (selectedTopFilter.value == 'popular') {
      list = list.where((p) => p.isPopular).toList();
    } else if (selectedTopFilter.value == 'combos') {
      list = list.where((p) => p.isCombo).toList();
    }

    // 2. Category filter
    if (selectedCategory.value != 'all') {
      list = list.where((p) {
        final catName = p.category.name.toLowerCase();
        return catName == selectedCategory.value.toLowerCase() ||
            p.id == selectedCategory.value;
      }).toList();
    }

    // 3. Search query
    if (searchQuery.value.isNotEmpty) {
      list = list.where((p) {
        return p.name.toLowerCase().contains(searchQuery.value);
      }).toList();
    }

    filteredProducts.assignAll(list);
  }

  // ===========================================================================
  // CART OPERATIONS
  // ===========================================================================

  void addToCart(ProductModel product) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(product: product, quantity: 1));
    }
  }

  void incrementQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      cartItems[index].quantity += 1;
      cartItems.refresh();
    }
  }

  void decrementQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity -= 1;
        cartItems.refresh();
      } else {
        cartItems.removeAt(index);
      }
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    cartItems.clear();
  }

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get tax => subtotal * 0.16; // 16% GST / Tax

  double get total => subtotal + tax;
}
