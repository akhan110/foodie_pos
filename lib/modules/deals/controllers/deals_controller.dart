import 'package:flutter/material.dart';
import 'package:foodiepos/modules/deals/models/deal_model.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';
import 'package:get/get.dart';

class DealsController extends GetxController {
  final Network _network = Network.instance;

  final RxList<DealModel> deals = <DealModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Filters & Search
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // All, Active, Inactive, Meal Combos, Family Deals, Limited Time
  final RxString selectedCategoryDropdown = 'All Deals'.obs;

  // Selected Deal for Right Editor Panel
  final Rx<DealModel?> selectedDeal = Rx<DealModel?>(null);
  final RxBool isCreatingNew = false.obs;

  // Form Fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final RxString category = 'Meal Combos'.obs;
  final RxBool isActive = true.obs;
  final RxString imageUrl = 'assets/svg/products/burger.svg'.obs;
  final RxList<DealItemModel> draftItems = <DealItemModel>[].obs;

  // Available Categories
  final List<String> availableCategories = [
    'Meal Combos',
    'Family Deals',
    'Limited Time',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDeals();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    super.onClose();
  }

  // ===========================================================================
  // FILTERED DEALS GETTER
  // ===========================================================================
  List<DealModel> get filteredDeals {
    return deals.where((d) {
      // 1. Status/Filter pill
      if (selectedFilter.value == 'Active' && !d.isActive) return false;
      if (selectedFilter.value == 'Inactive' && d.isActive) return false;
      if (['Meal Combos', 'Family Deals', 'Limited Time'].contains(selectedFilter.value)) {
        if (!d.category.toLowerCase().contains(selectedFilter.value.toLowerCase())) return false;
      }

      // 2. Dropdown Filter
      if (selectedCategoryDropdown.value != 'All Deals') {
        if (!d.category.toLowerCase().contains(selectedCategoryDropdown.value.toLowerCase())) return false;
      }

      // 3. Search Query
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final nameMatch = d.name.toLowerCase().contains(query);
        final descMatch = (d.description ?? '').toLowerCase().contains(query);
        if (!nameMatch && !descMatch) return false;
      }

      return true;
    }).toList();
  }

  // Counts for Pills
  int get totalCount => deals.length;
  int get activeCount => deals.where((d) => d.isActive).length;
  int get inactiveCount => deals.where((d) => !d.isActive).length;

  // ===========================================================================
  // PRICING & SAVINGS COMPUTATIONS
  // ===========================================================================
  double get originalTotal {
    return draftItems.fold(0.0, (sum, it) => sum + (it.unitPrice * it.quantity));
  }

  double get currentDealPrice {
    final parsed = double.tryParse(priceController.text.trim());
    return parsed ?? 0.0;
  }

  double get customerSaves {
    final orig = originalTotal;
    final dealPr = currentDealPrice;
    if (orig > dealPr && dealPr > 0) {
      return orig - dealPr;
    }
    return 0.0;
  }

  String get generatedDescription {
    if (draftItems.isEmpty) return 'Select items';
    return draftItems.map((e) => e.productName).join(' + ');
  }

  // ===========================================================================
  // DATA FETCHING & API ACTIONS
  // ===========================================================================
  Future<void> fetchDeals({bool showSpinner = true}) async {
    try {
      if (showSpinner) isLoading.value = true;

      final response = await _network.apiRequest<List<dynamic>>(
        requestType: ApiRequestType.get,
        endPoint: '/api/v1/deals',
        isBearerRequired: false,
        parser: (json) => json is List<dynamic> ? json : [],
      );

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        deals.value = response.data!
            .map((e) => DealModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Select first deal if none selected
        if (selectedDeal.value == null && deals.isNotEmpty) {
          selectDeal(deals.first);
        } else if (selectedDeal.value != null) {
          // Re-sync selected deal
          final match = deals.firstWhereOrNull((d) => d.id == selectedDeal.value!.id);
          if (match != null) {
            selectDeal(match);
          } else if (deals.isNotEmpty) {
            selectDeal(deals.first);
          }
        }
      } else {
        _setFallbackDeals();
      }
    } catch (e) {
      debugPrint('Deals fetch fallback used: $e');
      _setFallbackDeals();
    } finally {
      isLoading.value = false;
    }
  }

  void selectDeal(DealModel deal) {
    selectedDeal.value = deal;
    isCreatingNew.value = false;

    nameController.text = deal.name;
    priceController.text = deal.price.toStringAsFixed(0);
    category.value = deal.category;
    isActive.value = deal.isActive;
    imageUrl.value = deal.image;

    draftItems.value = deal.items
        .map((it) => it.copyWith())
        .toList();
  }

  void startNewDeal() {
    isCreatingNew.value = true;
    selectedDeal.value = null;

    nameController.text = '';
    priceController.text = '';
    category.value = 'Meal Combos';
    isActive.value = true;
    imageUrl.value = 'assets/svg/products/burger.svg';
    draftItems.clear();
  }

  void addProductToDeal(ProductModel product) {
    final existingIdx = draftItems.indexWhere((it) => it.productId == product.id || it.productName == product.name);
    if (existingIdx >= 0) {
      final existing = draftItems[existingIdx];
      existing.quantity += 1;
      existing.totalPrice = existing.quantity * existing.unitPrice;
      draftItems.refresh();
    } else {
      draftItems.add(
        DealItemModel(
          id: 'ditem-${DateTime.now().millisecondsSinceEpoch}',
          productId: product.id,
          productName: product.name,
          productImage: product.image,
          quantity: 1,
          unitPrice: product.price,
          totalPrice: product.price,
        ),
      );
    }
  }

  void addCustomItem({
    required String name,
    required double price,
    String image = 'assets/svg/products/burger.svg',
  }) {
    draftItems.add(
      DealItemModel(
        id: 'ditem-${DateTime.now().millisecondsSinceEpoch}',
        productName: name,
        productImage: image,
        quantity: 1,
        unitPrice: price,
        totalPrice: price,
      ),
    );
  }

  void removeItem(int index) {
    if (index >= 0 && index < draftItems.length) {
      draftItems.removeAt(index);
    }
  }

  void incrementItemQty(int index) {
    if (index >= 0 && index < draftItems.length) {
      draftItems[index].quantity += 1;
      draftItems[index].totalPrice = draftItems[index].quantity * draftItems[index].unitPrice;
      draftItems.refresh();
    }
  }

  void decrementItemQty(int index) {
    if (index >= 0 && index < draftItems.length) {
      if (draftItems[index].quantity > 1) {
        draftItems[index].quantity -= 1;
        draftItems[index].totalPrice = draftItems[index].quantity * draftItems[index].unitPrice;
        draftItems.refresh();
      } else {
        removeItem(index);
      }
    }
  }

  Future<void> saveDeal() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter a deal name', backgroundColor: Colors.amber, colorText: Colors.black);
      return;
    }

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar('Validation', 'Please enter a valid deal price', backgroundColor: Colors.amber, colorText: Colors.black);
      return;
    }

    if (draftItems.isEmpty) {
      Get.snackbar('Validation', 'Please add at least one product item to the deal', backgroundColor: Colors.amber, colorText: Colors.black);
      return;
    }

    try {
      isSaving.value = true;

      final dealData = {
        'name': name,
        'description': generatedDescription,
        'category': category.value,
        'price': price,
        'original_price': originalTotal,
        'discount_amount': customerSaves,
        'image': imageUrl.value,
        'is_active': isActive.value,
        'items': draftItems.map((it) => it.toJson()).toList(),
      };

      if (isCreatingNew.value || selectedDeal.value == null) {
        final resp = await _network.apiRequest<Map<String, dynamic>>(
          requestType: ApiRequestType.post,
          endPoint: '/api/v1/deals',
          requestData: dealData,
          isBearerRequired: false,
          parser: (json) => json is Map<String, dynamic> ? json : {},
        );

        if (resp.success) {
          Get.snackbar('Success', 'Deal created successfully!', backgroundColor: const Color(0xFF12B76A), colorText: Colors.white);
          await fetchDeals(showSpinner: false);
        }
      } else {
        final id = selectedDeal.value!.id;
        final resp = await _network.apiRequest<Map<String, dynamic>>(
          requestType: ApiRequestType.put,
          endPoint: '/api/v1/deals/$id',
          requestData: dealData,
          isBearerRequired: false,
          parser: (json) => json is Map<String, dynamic> ? json : {},
        );

        if (resp.success) {
          Get.snackbar('Success', 'Deal updated successfully!', backgroundColor: const Color(0xFF12B76A), colorText: Colors.white);
          await fetchDeals(showSpinner: false);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save deal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteDeal() async {
    final deal = selectedDeal.value;
    if (deal == null) return;

    try {
      isSaving.value = true;
      final resp = await _network.apiRequest<Map<String, dynamic>>(
        requestType: ApiRequestType.delete,
        endPoint: '/api/v1/deals/${deal.id}',
        isBearerRequired: false,
        parser: (json) => json is Map<String, dynamic> ? json : {},
      );

      if (resp.success) {
        Get.snackbar('Deleted', 'Deal removed successfully', backgroundColor: Colors.orange, colorText: Colors.white);
        selectedDeal.value = null;
        await fetchDeals(showSpinner: false);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete deal: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleDealStatus(DealModel deal) async {
    try {
      final resp = await _network.apiRequest<Map<String, dynamic>>(
        requestType: ApiRequestType.patch,
        endPoint: '/api/v1/deals/${deal.id}/toggle-status',
        isBearerRequired: false,
        parser: (json) => json is Map<String, dynamic> ? json : {},
      );

      if (resp.success) {
        deal.isActive = !deal.isActive;
        deals.refresh();
        if (selectedDeal.value?.id == deal.id) {
          isActive.value = deal.isActive;
        }
      }
    } catch (e) {
      debugPrint('Status toggle fallback: $e');
      deal.isActive = !deal.isActive;
      deals.refresh();
      if (selectedDeal.value?.id == deal.id) {
        isActive.value = deal.isActive;
      }
    }
  }

  void _setFallbackDeals() {
    deals.value = [
      DealModel(
        id: 'deal-1',
        name: 'Burger Combo',
        description: 'Burger + Fries + Drink',
        category: 'Meal Combos',
        price: 799.0,
        originalPrice: 1060.0,
        discountAmount: 261.0,
        image: 'assets/svg/products/burger.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd1', productName: 'Classic Smash Burger', unitPrice: 620, totalPrice: 620, quantity: 1, productImage: 'assets/svg/products/burger.svg'),
          DealItemModel(id: 'd2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 260, quantity: 1, productImage: 'assets/svg/products/fries.svg'),
          DealItemModel(id: 'd3', productName: 'Cola', unitPrice: 180, totalPrice: 180, quantity: 1, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-2',
        name: 'Pizza Family Deal',
        description: '2 Large Pizzas + 4 Drinks',
        category: 'Family Deals',
        price: 2999.0,
        originalPrice: 3500.0,
        discountAmount: 501.0,
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
        originalPrice: 1180.0,
        discountAmount: 330.0,
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
        description: 'Kids Burger + Fries + Juice',
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
        name: 'Snack Box',
        description: '2 Chicken + 2 Fries + 2 Drinks',
        category: 'Family Deals',
        price: 1199.0,
        originalPrice: 1560.0,
        discountAmount: 361.0,
        image: 'assets/svg/products/chicken.svg',
        isActive: false,
        items: [
          DealItemModel(id: 'd5-1', productName: 'Crunch Chicken', unitPrice: 500, totalPrice: 1000, quantity: 2, productImage: 'assets/svg/products/chicken.svg'),
          DealItemModel(id: 'd5-2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 520, quantity: 2, productImage: 'assets/svg/products/fries.svg'),
        ],
      ),
      DealModel(
        id: 'deal-6',
        name: 'Couple Deal',
        description: '1 Large Pizza + 2 Drinks',
        category: 'Limited Time',
        price: 1299.0,
        originalPrice: 1600.0,
        discountAmount: 301.0,
        image: 'assets/svg/products/pizza.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd6-1', productName: 'Pepperoni Pizza', unitPrice: 890, totalPrice: 890, quantity: 1, productImage: 'assets/svg/products/pizza.svg'),
          DealItemModel(id: 'd6-2', productName: 'Cola', unitPrice: 180, totalPrice: 360, quantity: 2, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-7',
        name: 'Dessert Deal',
        description: 'Any Sundae + Drink',
        category: 'Limited Time',
        price: 399.0,
        originalPrice: 550.0,
        discountAmount: 151.0,
        image: 'assets/svg/products/drink.svg',
        isActive: true,
        items: [
          DealItemModel(id: 'd7-1', productName: 'Chocolate Sundae', unitPrice: 320, totalPrice: 320, quantity: 1, productImage: 'assets/svg/products/drink.svg'),
          DealItemModel(id: 'd7-2', productName: 'Cola', unitPrice: 180, totalPrice: 180, quantity: 1, productImage: 'assets/svg/products/drink.svg'),
        ],
      ),
      DealModel(
        id: 'deal-8',
        name: 'Lunch Special',
        description: 'Burger + Fries + Drink',
        category: 'Limited Time',
        price: 699.0,
        originalPrice: 1060.0,
        discountAmount: 361.0,
        image: 'assets/svg/products/burger.svg',
        isActive: false,
        items: [
          DealItemModel(id: 'd8-1', productName: 'Classic Smash Burger', unitPrice: 620, totalPrice: 620, quantity: 1, productImage: 'assets/svg/products/burger.svg'),
          DealItemModel(id: 'd8-2', productName: 'Sea Salt Fries', unitPrice: 260, totalPrice: 260, quantity: 1, productImage: 'assets/svg/products/fries.svg'),
        ],
      ),
    ];

    if (deals.isNotEmpty && selectedDeal.value == null) {
      selectDeal(deals.first);
    }
  }
}
