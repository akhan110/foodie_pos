import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/modules/deals/controllers/deals_controller.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:get/get.dart';

void main() {
  group('DealsController Tests', () {
    late DealsController controller;

    setUp(() {
      Get.testMode = true;
      controller = DealsController();
    });

    test('1. Loads deals on init and sets fallback if offline', () async {
      await controller.fetchDeals(showSpinner: false);
      expect(controller.deals.isNotEmpty, true);
      expect(controller.selectedDeal.value, isNotNull);
      expect(controller.totalCount, greaterThan(0));
    });

    test('2. Filters deals by search query', () async {
      await controller.fetchDeals(showSpinner: false);

      controller.searchQuery.value = 'Pizza';
      final results = controller.filteredDeals;
      expect(results.every((d) => d.name.toLowerCase().contains('pizza') || (d.description ?? '').toLowerCase().contains('pizza')), true);

      controller.searchQuery.value = '';
    });

    test('3. Filters deals by status and category', () async {
      await controller.fetchDeals(showSpinner: false);

      controller.selectedFilter.value = 'Active';
      expect(controller.filteredDeals.every((d) => d.isActive), true);

      controller.selectedFilter.value = 'Inactive';
      expect(controller.filteredDeals.every((d) => !d.isActive), true);

      controller.selectedFilter.value = 'Family Deals';
      expect(controller.filteredDeals.every((d) => d.category.contains('Family')), true);

      controller.selectedFilter.value = 'All';
    });

    test('4. Computes originalTotal, dealPrice, customerSaves and generatedDescription accurately', () {
      controller.startNewDeal();
      controller.nameController.text = 'Super Burger Combo';
      controller.priceController.text = '800';

      const prod1 = ProductModel(
        id: 'p1',
        name: 'Smash Burger',
        category: ProductCategory.burgers,
        price: 600,
        image: 'assets/svg/products/burger.svg',
      );
      const prod2 = ProductModel(
        id: 'p2',
        name: 'Fries',
        category: ProductCategory.sides,
        price: 300,
        image: 'assets/svg/products/fries.svg',
      );

      controller.addProductToDeal(prod1);
      controller.addProductToDeal(prod2);

      expect(controller.draftItems.length, 2);
      expect(controller.originalTotal, 900.0);
      expect(controller.currentDealPrice, 800.0);
      expect(controller.customerSaves, 100.0);
      expect(controller.generatedDescription, 'Smash Burger + Fries');
    });

    test('5. Increments, decrements, and removes draft items', () {
      controller.startNewDeal();
      const prod = ProductModel(
        id: 'p1',
        name: 'Cola',
        category: ProductCategory.drinks,
        price: 150,
        image: 'assets/svg/products/drink.svg',
      );

      controller.addProductToDeal(prod);
      expect(controller.draftItems.first.quantity, 1);

      controller.incrementItemQty(0);
      expect(controller.draftItems.first.quantity, 2);
      expect(controller.originalTotal, 300.0);

      controller.decrementItemQty(0);
      expect(controller.draftItems.first.quantity, 1);

      controller.decrementItemQty(0);
      expect(controller.draftItems.isEmpty, true);
    });

    test('6. Toggles deal active/inactive status', () async {
      await controller.fetchDeals(showSpinner: false);
      final deal = controller.deals.first;
      final initialStatus = deal.isActive;

      await controller.toggleDealStatus(deal);
      expect(deal.isActive, !initialStatus);
    });
  });
}
