import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/theme/theme_controller.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/app/widgets/search_widget.dart';
import 'package:foodiepos/modules/shell/controllers/connectivity_controller.dart';
import 'package:get/get.dart';

class SecondaryAppBar extends StatefulWidget {
  const SecondaryAppBar({
    super.key,
    this.cashierName = 'Alex Khan',
    this.cashierRole = 'Cashier',
    this.storeName = 'Store #01',
    this.onSearchChanged,
  });

  final String cashierName;
  final String cashierRole;
  final String storeName;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<SecondaryAppBar> createState() => _SecondaryAppBarState();
}

class _SecondaryAppBarState extends State<SecondaryAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ConnectivityController connectivityController =
        Get.find<ConnectivityController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // ---------------- LOGO ----------------
          SizedBox(
            width: 140,
            height: 44,
            child: SvgPicture.asset(
              theme.brightness == Brightness.dark
                  ? 'assets/svg/biteflow_logo_dark.svg'
                  : 'assets/svg/biteflow_logo.svg',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),

          const SizedBox(width: 18),

          // ---------------- SEARCH ----------------
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 40,
                constraints: const BoxConstraints(maxWidth: 520),
                child: SearchWidget(
                  hintText: "Seach products, orders or customers. . ",
                  textEditingController: _searchController,
                  onChanged: widget.onSearchChanged,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // ---------------- ONLINE ----------------
          Obx(
            () => _StatusBadge(isOnline: connectivityController.isOnline.value),
          ),

          const SizedBox(width: 14),

          // ---------------- THEME ----------------
          Obx(
            () => IconButton(
              tooltip: themeController.isDarkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              onPressed: themeController.toggleTheme,
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ---------------- STORE ----------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: CustomTextWidget(
              widget.storeName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(width: 18),

          // ---------------- USER ----------------
          _CashierProfile(name: widget.cashierName, role: widget.cashierRole),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successSurface : AppColors.errorSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextWidget(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashierProfile extends StatelessWidget {
  const _CashierProfile({required this.name, required this.role});

  final String name;
  final String role;

  String get initials {
    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: CustomTextWidget(
            initials,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 9),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            CustomTextWidget(
              role,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
