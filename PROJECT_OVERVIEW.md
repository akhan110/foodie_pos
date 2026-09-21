# BiteFlow POS (`foodiepos`) — System Architecture & Knowledge Base

> **Single Source of Truth for Future Sessions**: This document contains everything needed to understand the BiteFlow POS codebase without re-analyzing the entire project.

---

## 📌 1. Project Overview & Tech Stack

* **Application Name**: BiteFlow POS (`foodiepos`)
* **Target Platforms**: Desktop (Windows/macOS/Linux) & Tablet (Landscape orientation, minimum supported width: `900px`).
* **Framework**: Flutter (Dart SDK `>=3.9.0`)
* **State Management & Routing**: [GetX](https://pub.dev/packages/get) (`GetView`, `GetxController`, `GetPage`, `Bindings`, `GetBuilder`, `Obx`).
* **Local Storage & Database**: 
  * `get_storage` (Key-value store initialized at app launch in [main.dart](file:///c:/Users/Akhan/Desktop/foodie_pos/foodiepos/lib/main.dart)).
  * `isar` & `isar_flutter_libs` (Offline-first local database for products and orders).
* **Network & Connectivity**: `internet_connection_checker_plus` (`ConnectivityController` for live online/offline badge).
* **Assets & Graphics**: `flutter_svg` for vector food icons and logos.

---

## 🗂️ 2. Directory Structure & File Map

```
lib/
├── main.dart                                   # App entry, GetStorage init, ThemeController injection, BiteFlowApp
├── app/
│   ├── constants/
│   │   └── assets_svg.dart                     # Static paths to SVG icons (burger, chicken, pizza, drink, etc.)
│   ├── routes/
│   │   ├── app_routes.dart                     # Route names: AppRoutes.login ('/login'), AppRoutes.pos ('/pos')
│   │   └── app_pages.dart                      # GetPage routing list with respective Bindings
│   ├── theme/
│   │   ├── app_colors.dart                     # Core color palette (primary: #FF6B35, dark & light theme tokens)
│   │   ├── app_theme.dart                      # Material 3 ThemeData (lightTheme, darkTheme)
│   │   └── theme_controller.dart               # GetxController toggling & persisting light/dark mode in GetStorage
│   └── widgets/
│       ├── app_bar_widget.dart                 # SecondaryAppBar (Logo, SearchBar, Online badge, Theme toggle, User profile)
│       ├── custom_text_widget.dart             # Text wrapper supporting style, ellipsis, maxLines
│       ├── search_widget.dart                  # TextFormField with clear and filter action buttons
│       └── unsupported_screen_view.dart        # Guard screen shown if window width < 900px
├── data/
│   ├── data/dummy/
│   │   └── dummy_model_data.dart               # ProductDummyData with mock burgers, pizza, chicken, drinks, combos
│   ├── models/                                 # API and Local DB transfer models
│   ├── repositories/                           # Data repositories (combines Isar DB + Remote API)
│   └── services/                               # HTTP client (GetConnect / Dio) & Sync engine
└── modules/
    ├── login/
    │   ├── bindings/login_bindings.dart        # Injects LoginController & ConnectivityController
    │   ├── controllers/login_controller.dart   # Reactive PIN management, backspace, and '1234' validation
    │   └── views/login_view.dart               # Split screen (Left: Hero branding; Right: Interactive PIN keypad)
    ├── shell/
    │   ├── binding/shell_binding.dart          # Shell bindings
    │   ├── controller/main_shell_controller.dart # Active sidebar index navigation (0: Dashboard, 1: POS, 2: Orders, etc.)
    │   ├── controllers/connectivity_controller.dart # RxBool isOnline listening to live network changes
    │   └── views/
    │       ├── main_shell_view.dart            # LayoutBuilder (900px guard), SecondaryAppBar, SideNavigation, Page switcher
    │       └── new_order_view.dart             # POS Main View: ProductSection (Expanded) + CartSection (360px width)
    └── pos/
        ├── bindings/pos_binding.dart           # Injects PosController, MainShellController, ConnectivityController
        ├── controllers/pos_controller.dart     # POS & Cart state management controller
        ├── model/
        │   ├── cart_model.dart                 # Cart item data model (product, quantity, notes)
        │   ├── product_category.dart           # Enum: burgers, chicken, pizza, sides, drinks, desserts
        │   └── product_model.dart              # ProductModel (id, name, category, price, image, isPopular, isCombo)
        ├── views/pos_view.dart                 # POS root view wrapping MainShellView(child: NewOrderView())
        └── widgets/
            ├── side_navigation.dart            # Left sidebar with 7 tabs (Dashboard, New Order, Orders, Menu, Reports, Users, Settings)
            └── new_order/
                ├── left_view_products/
                │   ├── new_order_header.dart   # Page title, Top filter chips (All, Popular, Combos), Category chips
                │   ├── product_card.dart       # Product item card (image, name, price, + Add button)
                │   ├── product_grid.dart       # Responsive GridView adapting crossAxisCount (2 to 5 columns)
                │   └── product_section.dart    # Left container combining header and product grid
                └── right_view_cart/
                    ├── cart_item_list.dart     # Scrollable ListView of active cart items
                    ├── cart_item_tile.dart     # 2-Tier overflow-proof tile (Top: Image+Title+Delete; Bottom: Stepper+Price)
                    ├── cart_section.dart       # Cart container with header, clear all, order type tabs, and item list
                    └── order_type_tabs.dart    # Chips for 'Dine in', 'Takeaway', 'Delivery'
```

---

## 🎨 3. Key Design Rules & Conventions

1. **Responsive Proportions**:
   * Minimum POS breakpoint is **`900px`**. Any width below this automatically displays `UnsupportedScreenView`.
   * The `NewOrderView` uses `Expanded(child: ProductSection())` on the left and a dedicated `SizedBox(width: 360, child: CartSection())` on the right.
2. **Cart Item Tile Design**:
   * Always maintain the **2-tier layout** in `CartItemTile` (Top: thumbnail + title + remove button; Bottom: stepper + price). This guarantees zero horizontal pixel overflow across all desktop window sizes.
3. **Theming & Colors**:
   * Do **not** hardcode hex colors.
   * Brand colors: `AppColors.primary` (`#FF6B35`), `AppColors.success` (`#12B76A`), `AppColors.error` (`#F04438`).
   * Surfaces & backgrounds: `theme.colorScheme.surface`, `theme.colorScheme.onSurface`, `theme.colorScheme.outline`, `theme.dividerColor`.
4. **State Management Flow**:
   * Navigation routes are defined in `AppRoutes` and registered in `AppPages`.
   * Keep controllers lightweight; inject using `Bindings` on route definitions.

---

## 🔑 4. Authentication / PIN Details
* Current PIN for testing: **`1234`**
* Keypad accepts numbers 0–9, backspace icon, checkmark icon, or the **Login** button.
* On success: `Get.offNamed(AppRoutes.pos)`.

---

## 🚀 5. Roadmap & Next Modules to Build

1. **Reactive Cart in `PosController`**:
   * Implement `RxList<CartItemModel> cartItems = <CartItemModel>[].obs;`
   * Wire `+ Add` on `ProductCard` to add items to the cart.
   * Connect stepper (`+` / `-`) and `onRemove` in `CartItemTile`.
   * Add reactive order calculation (Subtotal, Tax %, Discount, Total).
2. **Category & Search Filtering**:
   * Connect category chips in `NewOrderHeader` to filter products in `ProductGrid`.
   * Connect search query from `SecondaryAppBar` to live product search.
3. **Order Placement & Isar Local DB**:
   * Store placed orders in local Isar collections for offline reliability.
   * Generate sequential receipt numbers (`#0001`, `#0002`).
4. **Backend Sync**:
   * Setup `ApiService` to sync offline orders when `ConnectivityController.isOnline` is true.
