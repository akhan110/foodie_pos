import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/data/models/cashier_model.dart';
import 'package:foodiepos/modules/shell/controllers/connectivity_controller.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 900;

          if (isSmallScreen) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildLoginCard(context, colors, isDark),
              ),
            );
          }

          return Row(
            children: [
              // =========================================================
              // LEFT SIDE (Hero / Branding)
              // =========================================================
              Expanded(
                flex: 11,
                child: Container(
                  height: double.infinity,
                  color: isDark
                      ? AppColors.darkSidebar
                      : AppColors.lightSurfaceSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 36,
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 72).clamp(0, double.infinity),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LOGO
                            SizedBox(
                              height: 64,
                              child: SvgPicture.asset(
                                isDark
                                    ? 'assets/svg/biteflow_logo_dark.svg'
                                    : 'assets/svg/biteflow_logo.svg',
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 24),

                            // TITLE
                            CustomTextWidget(
                              'Fast checkout.\nHappy customers.',
                              style: TextStyle(
                                fontSize: 44,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 16),

                            CustomTextWidget(
                              'A clean POS designed for busy fast-food counters.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Spacer(),

                            CustomTextWidget(
                              '© BiteFlow POS • All rights reserved',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // =========================================================
              // RIGHT SIDE (Keypad & Login Card)
              // =========================================================
              Expanded(
                flex: 9,
                child: Container(
                  height: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _buildLoginCard(context, colors, isDark),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    ColorScheme colors,
    bool isDark,
  ) {
    final connectivityController = Get.isRegistered<ConnectivityController>()
        ? Get.find<ConnectivityController>()
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: CustomTextWidget(
                  'Welcome back',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // ONLINE STATUS
              if (connectivityController != null)
                Obx(
                  () => _StatusBadge(
                    isOnline: connectivityController.isOnline.value,
                  ),
                )
              else
                const _StatusBadge(isOnline: true),
            ],
          ),

          const SizedBox(height: 6),

          CustomTextWidget(
            'Select your account and enter 4-digit PIN',
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),

          // CASHIER / USER SELECTION DROPDOWN
          Obx(() {
            final selected = controller.selectedCashier.value;
            final cashiers = controller.cashiers;

            if (cashiers.isEmpty) {
              return const SizedBox(height: 10);
            }

            return Container(
              margin: const EdgeInsets.only(top: 14, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252A36) : const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF2D333F) : Theme.of(context).dividerColor,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CashierModel>(
                  value: cashiers.contains(selected) ? selected : cashiers.first,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                  dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  onChanged: controller.selectCashier,
                  items: cashiers.map((cashier) {
                    return DropdownMenuItem<CashierModel>(
                      value: cashier,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: CustomTextWidget(
                              cashier.name.isNotEmpty ? cashier.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                  cashier.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                CustomTextWidget(
                                  '${cashier.role.capitalizeFirst ?? cashier.role} • ${cashier.storeName}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),

          // KDS MODE CHECKBOX
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => controller.isKdsMode.toggle(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => SizedBox(
                        height: 22,
                        width: 22,
                        child: Checkbox(
                          value: controller.isKdsMode.value,
                          onChanged: (val) => controller.isKdsMode.value = val ?? false,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: CustomTextWidget(
                        'Kitchen Display System (KDS Mode)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // PIN INDICATOR DOTS
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < controller.pin.value.length;
                return _PinDot(filled: isFilled);
              }),
            ),
          ),

          // ERROR MESSAGE DISPLAY
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox(height: 20);
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: CustomTextWidget(
                controller.errorMessage.value,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),

          // NUMBER PAD
          _NumberPad(
            onNumberTap: controller.onNumberPressed,
            onDeleteTap: controller.onDeletePressed,
            onCheckTap: controller.verifyPin,
          ),

          const SizedBox(height: 18),

          // LOGIN BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const CustomTextWidget(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // USERNAME PASSWORD BUTTON
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onSurface,
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const CustomTextWidget(
                'Use username & password',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // SIGN UP LINK
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomTextWidget(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.signup),
                child: const CustomTextWidget(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          CustomTextWidget(
            'BiteFlow POS v1.0 · Store #01',
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successSurface : AppColors.errorSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: isOnline ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 6),
          CustomTextWidget(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PIN DOT
// ============================================================================

class _PinDot extends StatelessWidget {
  const _PinDot({this.filled = false});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: filled ? AppColors.primary : colors.outline,
          width: 2,
        ),
      ),
    );
  }
}

// ============================================================================
// NUMBER PAD
// ============================================================================

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onNumberTap,
    required this.onDeleteTap,
    required this.onCheckTap,
  });

  final ValueChanged<String> onNumberTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onCheckTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(['1', '2', '3']),
        const SizedBox(height: 10),
        _row(['4', '5', '6']),
        const SizedBox(height: 10),
        _row(['7', '8', '9']),
        const SizedBox(height: 10),
        _bottomRow(context),
      ],
    );
  }

  Widget _row(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: number == numbers.last ? 0 : 10),
            child: _NumberButton(
              onTap: () => onNumberTap(number),
              child: CustomTextWidget(
                number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bottomRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NumberButton(
            onTap: onDeleteTap,
            child: const Icon(Icons.backspace_outlined, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NumberButton(
            onTap: () => onNumberTap('0'),
            child: const CustomTextWidget(
              '0',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NumberButton(
            onTap: onCheckTap,
            child: const Icon(
              Icons.check_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// NUMBER BUTTON
// ============================================================================

class _NumberButton extends StatelessWidget {
  const _NumberButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: IconTheme(
            data: IconThemeData(color: colors.onSurface),
            child: DefaultTextStyle(
              style: TextStyle(color: colors.onSurface),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
