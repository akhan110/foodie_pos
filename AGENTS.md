# BiteFlow POS — Agent Guidelines & Project Map

This project is **BiteFlow POS** (`foodiepos`), a modern, offline-first fast-food Point of Sale application built with **Flutter** and **GetX**.

For detailed system architecture, file structure, and design rules, refer to [PROJECT_OVERVIEW.md](file:///c:/Users/Akhan/Desktop/foodie_pos/foodiepos/PROJECT_OVERVIEW.md).

## Quick Architecture Summary
- **Framework & State Management**: Flutter + GetX (`GetView`, `GetBuilder`, `GetPage`, `Bindings`).
- **Storage**: `get_storage` (theme, auth state), `isar` (offline database).
- **Network**: `internet_connection_checker_plus` (`ConnectivityController`).
- **Screen Breakpoint**: Minimum width `900px` (`UnsupportedScreenView` shown below 900px).
- **Layout Model**: `ProductSection` is `Expanded`, `CartSection` has a fixed responsive width of `360px`.
- **Cart Item Layout**: 2-tier layout (Top: Image + Title + Delete; Bottom: Stepper + Price) to prevent horizontal overflow.
- **Login PIN**: `1234` navigates to `AppRoutes.pos`.
- **Colors**: Always use `AppColors` and `Theme.of(context).colorScheme` for dark/light theme support.
