import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:get/get.dart';

class SideNavigation extends GetView<MainShellController> {
  const SideNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.sidebar(context),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: GetBuilder<MainShellController>(
        id: 'shell',
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SideNavItem(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                isSelected: controller.selectedIndex == 0,
                onTap: () => controller.changePage(0),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.shopping_cart_outlined,
                title: 'New Order',
                isSelected: controller.selectedIndex == 1,
                onTap: () => controller.changePage(1),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.receipt_long_outlined,
                title: 'Orders',
                isSelected: controller.selectedIndex == 2,
                onTap: () => controller.changePage(2),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.restaurant_menu_outlined,
                title: 'Menu',
                isSelected: controller.selectedIndex == 3,
                onTap: () => controller.changePage(3),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.card_giftcard_outlined,
                title: 'Deals',
                isSelected: controller.selectedIndex == 4,
                onTap: () => controller.changePage(4),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.bar_chart_outlined,
                title: 'Reports',
                isSelected: controller.selectedIndex == 5,
                onTap: () => controller.changePage(5),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.people_outline,
                title: 'Users',
                isSelected: controller.selectedIndex == 6,
                onTap: () => controller.changePage(6),
              ),
              const SizedBox(height: 8),

              _SideNavItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                isSelected: controller.selectedIndex == 7,
                onTap: () => controller.changePage(7),
              ),

              const Spacer(),

              // BOTTOM LOGOUT BUTTON
              _LogoutNavItem(
                onTap: () => controller.confirmLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutNavItem extends StatelessWidget {
  const _LogoutNavItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppColors.error.withValues(alpha: 0.12),
        splashColor: AppColors.error.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.error,
              ),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
