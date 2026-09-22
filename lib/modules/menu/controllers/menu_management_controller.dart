import 'package:flutter/material.dart';
import 'package:foodiepos/data/data/dummy/dummy_model_data.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
import 'package:get/get.dart';

class MenuManagementController extends GetxController {
  final IPosRepository _repository;

  MenuManagementController({IPosRepository? repository})
      : _repository = repository ?? PosRepository();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<ProductCategoryModel> categories = <ProductCategoryModel>[].obs;

  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  // Editor Form State
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxBool isCreatingNew = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString formCategory = 'burgers'.obs;
  final RxBool formIsAvailable = true.obs;
  final RxString formImage = 'assets/svg/products/burger.svg'.obs;

  // Add-ons for current category/product
  final RxList<ProductExtraItem> currentAddons = <ProductExtraItem>[].obs;
  final RxBool isLoadingAddons = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMenu();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> loadMenu() async {
    try {
      isLoading.value = true;

      final catRes = await _repository.getCategories();
      if (catRes.success && catRes.data != null && catRes.data!.isNotEmpty) {
        categories.assignAll(catRes.data!);
      } else {
        categories.assignAll([
          ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
          ProductCategoryModel(id: 'chicken', name: 'Chicken', slug: 'chicken'),
          ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
          ProductCategoryModel(id: 'sides', name: 'Sides', slug: 'sides'),
          ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
          ProductCategoryModel(id: 'desserts', name: 'Desserts', slug: 'desserts'),
        ]);
      }

      final prodRes = await _repository.getProducts(includeInactive: true);
      if (prodRes.success && prodRes.data != null && prodRes.data!.isNotEmpty) {
        products.assignAll(prodRes.data!);
      } else {
        products.assignAll(ProductDummyData.products);
      }

      _applyFilters();

      // Default select first product if available
      if (products.isNotEmpty && selectedProduct.value == null && !isCreatingNew.value) {
        selectProduct(products.first);
      }
    } catch (_) {
      products.assignAll(ProductDummyData.products);
      _applyFilters();
      if (products.isNotEmpty) {
        selectProduct(products.first);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategoryFilter(String categoryId) {
    selectedCategory.value = categoryId;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  void _applyFilters() {
    List<ProductModel> list = List.from(products);

    if (selectedCategory.value != 'all') {
      list = list.where((p) {
        return p.category.name.toLowerCase() == selectedCategory.value.toLowerCase() ||
            p.id == selectedCategory.value;
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(searchQuery.value)).toList();
    }

    filteredProducts.assignAll(list);
  }

  int getCategoryCount(String categoryId) {
    if (categoryId == 'all') return products.length;
    return products.where((p) => p.category.name.toLowerCase() == categoryId.toLowerCase()).length;
  }

  void selectProduct(ProductModel product) {
    isCreatingNew.value = false;
    selectedProduct.value = product;

    nameController.text = product.name;
    priceController.text = product.price.toStringAsFixed(0);
    descriptionController.text = product.description ?? _getDefaultDescription(product.category.name);
    formCategory.value = product.category.name.toLowerCase();
    formIsAvailable.value = product.isActive;
    formImage.value = product.image;

    fetchAddonsForCategory(product.category.name.toLowerCase());
  }

  void startNewProduct() {
    isCreatingNew.value = true;
    selectedProduct.value = null;

    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    formCategory.value = categories.isNotEmpty ? categories.first.id : 'burgers';
    formIsAvailable.value = true;
    formImage.value = _getImageForCategory(formCategory.value);

    fetchAddonsForCategory(formCategory.value);
  }

  void onCategoryFormChanged(String newCat) {
    formCategory.value = newCat;
    formImage.value = _getImageForCategory(newCat);
    fetchAddonsForCategory(newCat);
  }

  Future<void> fetchAddonsForCategory(String categoryId) async {
    try {
      isLoadingAddons.value = true;
      final res = await _repository.getAddons(categoryId: categoryId);
      if (res.success && res.data != null) {
        currentAddons.assignAll(res.data!);
      } else {
        currentAddons.clear();
      }
    } catch (_) {
      currentAddons.clear();
    } finally {
      isLoadingAddons.value = false;
    }
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final description = descriptionController.text.trim();

    if (name.isEmpty) {
      _showNotification('Validation Error', 'Please enter a product name', isError: true);
      return;
    }

    if (price <= 0) {
      _showNotification('Validation Error', 'Please enter a valid price', isError: true);
      return;
    }

    try {
      isSaving.value = true;

      final payload = {
        'name': name,
        'category_id': formCategory.value,
        'price': price,
        'description': description,
        'image': formImage.value,
        'is_active': formIsAvailable.value,
      };

      if (isCreatingNew.value) {
        final res = await _repository.createProduct(payload);
        if (res.success && res.data != null) {
          products.insert(0, res.data!);
          selectProduct(res.data!);
        } else {
          final newProd = ProductModel.fromJson({
            ...payload,
            'id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
          });
          products.insert(0, newProd);
          selectProduct(newProd);
        }
        _showNotification('Success', 'Product created successfully');
      } else {
        final current = selectedProduct.value!;
        final res = await _repository.updateProduct(current.id, payload);

        ProductModel updated;
        if (res.success && res.data != null) {
          updated = res.data!;
        } else {
          updated = current.copyWith(
            name: name,
            category: ProductCategory.values.firstWhere(
              (e) => e.name.toLowerCase() == formCategory.value.toLowerCase(),
              orElse: () => ProductCategory.burgers,
            ),
            price: price,
            description: description,
            image: formImage.value,
            isActive: formIsAvailable.value,
          );
        }

        final idx = products.indexWhere((p) => p.id == current.id);
        if (idx >= 0) {
          products[idx] = updated;
        }
        selectProduct(updated);

        _showNotification('Success', 'Product updated successfully');
      }

      _applyFilters();
      _syncWithPosController();
    } catch (e) {
      _showNotification('Error', 'Failed to save product: $e', isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isDeleting.value = true;
      await _repository.deleteProduct(productId);

      products.removeWhere((p) => p.id == productId);
      _applyFilters();

      if (products.isNotEmpty) {
        selectProduct(products.first);
      } else {
        startNewProduct();
      }

      _syncWithPosController();
      _showNotification('Deleted', 'Item deleted successfully');
    } catch (e) {
      _showNotification('Error', 'Failed to delete product: $e', isError: true);
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleProductAvailability(ProductModel product) async {
    final updated = product.copyWith(isActive: !product.isActive);
    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      products[idx] = updated;
      _applyFilters();
      if (selectedProduct.value?.id == product.id) {
        formIsAvailable.value = updated.isActive;
        selectedProduct.value = updated;
      }
    }

    try {
      await _repository.updateProduct(product.id, {'is_active': updated.isActive});
      _syncWithPosController();
    } catch (_) {}
  }

  Future<void> addNewAddon(String name, double price) async {
    try {
      final payload = {
        'name': name,
        'price': price,
        'category_id': formCategory.value,
        'is_active': true,
      };
      final res = await _repository.createAddon(payload);
      if (res.success && res.data != null) {
        currentAddons.add(res.data!);
      } else {
        currentAddons.add(ProductExtraItem(
          id: 'add_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: price,
        ));
      }
      _showNotification('Add-on Added', '$name added to ${formCategory.value}');
    } catch (e) {
      _showNotification('Error', 'Failed to add addon: $e', isError: true);
    }
  }

  Future<void> removeAddon(String addonId) async {
    try {
      await _repository.deleteAddon(addonId);
      currentAddons.removeWhere((a) => a.id == addonId);
    } catch (_) {
      currentAddons.removeWhere((a) => a.id == addonId);
    }
  }

  void _showNotification(String title, String message, {bool isError = false}) {
    if (Get.testMode == true) return;
    try {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {}
  }

  void _syncWithPosController() {
    if (Get.isRegistered<PosController>()) {
      final pos = Get.find<PosController>();
      pos.fetchProducts();
    }
  }

  String _getImageForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('chicken')) return 'assets/svg/products/chicken.svg';
    if (c.contains('pizza')) return 'assets/svg/products/pizza.svg';
    if (c.contains('side') || c.contains('fries')) return 'assets/svg/products/fries.svg';
    if (c.contains('drink')) return 'assets/svg/products/drink.svg';
    if (c.contains('dessert')) return 'assets/svg/products/dessert.svg';
    return 'assets/svg/products/burger.svg';
  }

  String _getDefaultDescription(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('burger')) return 'Juicy smashed beef patty with fresh lettuce, tomato, cheese and our special sauce.';
    if (c.contains('pizza')) return 'Crispy hand-stretched crust topped with rich mozzarella & herbs.';
    if (c.contains('chicken')) return 'Crispy seasoned golden chicken fried to perfection.';
    if (c.contains('side') || c.contains('fries')) return 'Golden crispy sea salt fries served piping hot.';
    if (c.contains('drink')) return 'Refreshing chilled beverage served over ice.';
    if (c.contains('dessert')) return 'Rich velvety sundae with indulgent chocolate syrup.';
    return 'Delicious fresh menu item prepared with quality ingredients.';
  }
}
