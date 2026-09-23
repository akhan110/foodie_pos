import 'package:file_picker/file_picker.dart';
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

  // Tabs: 0 = Products, 1 = Categories & Add-ons
  final RxInt selectedTab = 0.obs;

  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  // Editor Form State
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxBool isCreatingNew = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString formCategory = 'burgers'.obs;
  final RxBool formIsAvailable = true.obs;
  final RxBool formIsKitchen = true.obs;
  final RxString formImage = 'assets/svg/products/burger.svg'.obs;

  // Add-ons for current category/product editor
  final RxList<ProductExtraItem> currentAddons = <ProductExtraItem>[].obs;
  final RxBool isLoadingAddons = false.obs;

  // All Add-ons for Categories & Add-ons view
  final RxList<ProductExtraItem> allAddons = <ProductExtraItem>[].obs;
  final RxBool isLoadingAllAddons = false.obs;

  // Sizes for current category/product
  final RxList<ProductSizeOption> currentSizes = <ProductSizeOption>[].obs;
  final RxBool isLoadingSizes = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMenu();
  }

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
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
      loadAllAddons();

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

  Future<void> loadAllAddons() async {
    try {
      isLoadingAllAddons.value = true;
      final res = await _repository.getAddons();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        allAddons.assignAll(res.data!);
      } else {
        allAddons.assignAll([
          const ProductExtraItem(id: 'b_cheese', name: 'Extra cheese', price: 90.0, isActive: true),
          const ProductExtraItem(id: 'b_jalapenos', name: 'Jalapeños', price: 60.0, isActive: true),
          const ProductExtraItem(id: 'b_patty', name: 'Extra patty', price: 220.0, isActive: true),
          const ProductExtraItem(id: 'b_sauce', name: 'Special sauce', price: 50.0, isActive: true),
          const ProductExtraItem(id: 's_fries', name: 'Large fries upgrade', price: 120.0, isActive: true),
        ]);
      }
    } catch (_) {
      allAddons.assignAll([
        const ProductExtraItem(id: 'b_cheese', name: 'Extra cheese', price: 90.0, isActive: true),
        const ProductExtraItem(id: 'b_jalapenos', name: 'Jalapeños', price: 60.0, isActive: true),
        const ProductExtraItem(id: 'b_patty', name: 'Extra patty', price: 220.0, isActive: true),
        const ProductExtraItem(id: 'b_sauce', name: 'Special sauce', price: 50.0, isActive: true),
        const ProductExtraItem(id: 's_fries', name: 'Large fries upgrade', price: 120.0, isActive: true),
      ]);
    } finally {
      isLoadingAllAddons.value = false;
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
    skuController.text = product.sku ?? product.effectiveSku;
    priceController.text = product.price.toStringAsFixed(0);
    descriptionController.text = product.description ?? _getDefaultDescription(product.category.name);
    formCategory.value = product.category.name.toLowerCase();
    formIsAvailable.value = product.isActive;
    formIsKitchen.value = product.isKitchen;
    formImage.value = product.image;

    fetchAddonsForCategory(product.category.name.toLowerCase());
    fetchSizesForCategory(product.category.name.toLowerCase());
  }

  void startNewProduct() {
    isCreatingNew.value = true;
    selectedProduct.value = null;

    final defaultCat = categories.isNotEmpty ? categories.first.id : 'burgers';
    nameController.clear();
    skuController.text = '${defaultCat.substring(0, defaultCat.length >= 3 ? 3 : defaultCat.length).toUpperCase()}-001';
    priceController.clear();
    descriptionController.clear();
    formCategory.value = defaultCat;
    formIsAvailable.value = true;
    formIsKitchen.value = true;
    formImage.value = _getImageForCategory(formCategory.value);

    fetchAddonsForCategory(formCategory.value);
    fetchSizesForCategory(formCategory.value);
  }

  void onCategoryFormChanged(String newCat) {
    formCategory.value = newCat;
    formImage.value = _getImageForCategory(newCat);
    if (isCreatingNew.value) {
      skuController.text = '${newCat.substring(0, newCat.length >= 3 ? 3 : newCat.length).toUpperCase()}-001';
    }
    fetchAddonsForCategory(newCat);
    fetchSizesForCategory(newCat);
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

  Future<void> fetchSizesForCategory(String categoryId) async {
    try {
      isLoadingSizes.value = true;
      final res = await _repository.getSizeOptions(categoryId: categoryId);
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        currentSizes.assignAll(res.data!);
      } else {
        currentSizes.assignAll([
          const ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
          const ProductSizeOption(id: 'large', name: 'Large', extraPrice: 120.0),
          const ProductSizeOption(id: 'xl', name: 'XL', extraPrice: 220.0),
        ]);
      }
    } catch (_) {
      currentSizes.assignAll([
        const ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
        const ProductSizeOption(id: 'large', name: 'Large', extraPrice: 120.0),
        const ProductSizeOption(id: 'xl', name: 'XL', extraPrice: 220.0),
      ]);
    } finally {
      isLoadingSizes.value = false;
    }
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final sku = skuController.text.trim();
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
        'sku': sku.isNotEmpty ? sku : null,
        'category_id': formCategory.value,
        'price': price,
        'description': description,
        'image': formImage.value,
        'is_active': formIsAvailable.value,
        'is_kitchen': formIsKitchen.value,
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
            sku: sku,
            category: ProductCategory.values.firstWhere(
              (e) => e.name.toLowerCase() == formCategory.value.toLowerCase(),
              orElse: () => ProductCategory.burgers,
            ),
            price: price,
            description: description,
            image: formImage.value,
            isActive: formIsAvailable.value,
            isKitchen: formIsKitchen.value,
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

  // ============================================================
  // CATEGORIES CRUD
  // ============================================================
  Future<void> createCategory(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    try {
      final res = await _repository.createCategory({
        'name': cleanName,
        'sort_order': categories.length,
      });

      if (res.success && res.data != null) {
        categories.add(res.data!);
      } else {
        categories.add(ProductCategoryModel(
          id: cleanName.toLowerCase().replaceAll(' ', '_'),
          name: cleanName,
          slug: cleanName.toLowerCase().replaceAll(' ', '_'),
          productCount: 0,
        ));
      }
      _showNotification('Success', 'Category "$cleanName" created');
    } catch (e) {
      _showNotification('Error', 'Failed to create category: $e', isError: true);
    }
  }

  Future<void> updateCategory(String id, String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    try {
      final res = await _repository.updateCategory(id, {'name': cleanName});
      if (res.success && res.data != null) {
        final idx = categories.indexWhere((c) => c.id == id);
        if (idx >= 0) categories[idx] = res.data!;
      } else {
        final idx = categories.indexWhere((c) => c.id == id);
        if (idx >= 0) categories[idx] = categories[idx].copyWith(name: cleanName);
      }
      _showNotification('Success', 'Category updated');
    } catch (e) {
      _showNotification('Error', 'Failed to update category: $e', isError: true);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      products.removeWhere((p) => p.category.name.toLowerCase() == id.toLowerCase());
      _applyFilters();
      _showNotification('Deleted', 'Category deleted');
    } catch (e) {
      _showNotification('Error', 'Failed to delete category: $e', isError: true);
    }
  }

  // ============================================================
  // GLOBAL ADD-ONS CRUD & TOGGLE
  // ============================================================
  Future<void> toggleAddon(ProductExtraItem addon) async {
    final newStatus = !addon.isActive;
    final updated = addon.copyWith(isActive: newStatus);

    final idx = allAddons.indexWhere((a) => a.id == addon.id);
    if (idx >= 0) allAddons[idx] = updated;

    try {
      await _repository.toggleAddonStatus(addon.id);
    } catch (_) {}
  }

  Future<void> createAddonGlobal(String name, double price, {String? categoryId}) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    try {
      final res = await _repository.createAddon({
        'name': cleanName,
        'price': price,
        'category_id': categoryId,
        'is_active': true,
      });

      if (res.success && res.data != null) {
        allAddons.add(res.data!);
      } else {
        allAddons.add(ProductExtraItem(
          id: 'add_${DateTime.now().millisecondsSinceEpoch}',
          name: cleanName,
          price: price,
          isActive: true,
          categoryId: categoryId,
        ));
      }
      _showNotification('Success', 'Add-on "$cleanName" created');
    } catch (e) {
      _showNotification('Error', 'Failed to create add-on: $e', isError: true);
    }
  }

  Future<void> deleteAddonGlobal(String id) async {
    try {
      await _repository.deleteAddon(id);
      allAddons.removeWhere((a) => a.id == id);
      _showNotification('Deleted', 'Add-on deleted');
    } catch (e) {
      _showNotification('Error', 'Failed to delete add-on: $e', isError: true);
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

  Future<void> addNewSizeOption(String name, double extraPrice) async {
    try {
      final payload = {
        'name': name,
        'extra_price': extraPrice,
        'category_id': formCategory.value,
        'is_active': true,
      };
      final res = await _repository.createSizeOption(payload);
      if (res.success && res.data != null) {
        currentSizes.add(res.data!);
      } else {
        currentSizes.add(ProductSizeOption(
          id: 'sz_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          extraPrice: extraPrice,
        ));
      }
      _showNotification('Size Added', '$name (+ Rs ${extraPrice.toStringAsFixed(0)}) added to ${formCategory.value}');
    } catch (e) {
      _showNotification('Error', 'Failed to add size: $e', isError: true);
    }
  }

  Future<void> removeSizeOption(String sizeId) async {
    try {
      await _repository.deleteSizeOption(sizeId);
      currentSizes.removeWhere((s) => s.id == sizeId);
    } catch (_) {
      currentSizes.removeWhere((s) => s.id == sizeId);
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

  final RxBool isUploadingImage = false.obs;

  Future<void> pickAndUploadRealImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'svg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      isUploadingImage.value = true;
      _showNotification('Uploading', 'Uploading ${file.name}...');

      if (file.path != null && file.path!.isNotEmpty) {
        final res = await _repository.uploadImage(
          file.path!,
          bytes: file.bytes,
          filename: file.name,
        );

        if (res.success && res.data != null && res.data!.isNotEmpty) {
          formImage.value = res.data!;
          _showNotification('Success', 'Image uploaded successfully!');
        } else {
          // Fallback to local path for instant preview
          formImage.value = file.path!;
          _showNotification('Image Selected', file.name);
        }
      } else if (file.bytes != null) {
        final res = await _repository.uploadImage(
          file.name,
          bytes: file.bytes,
          filename: file.name,
        );
        if (res.success && res.data != null && res.data!.isNotEmpty) {
          formImage.value = res.data!;
          _showNotification('Success', 'Image uploaded successfully!');
        }
      }
    } catch (e) {
      _showNotification('Upload Error', 'Could not upload image: $e', isError: true);
    } finally {
      isUploadingImage.value = false;
    }
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
