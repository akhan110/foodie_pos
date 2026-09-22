import 'package:flutter/material.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/signup/controllers/signup_controller.dart';
import 'package:get/get.dart';

class SignupFormCard extends GetView<SignupController> {
  const SignupFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // TITLE & SUBTITLE
          Center(
            child: Column(
              children: [
                CustomTextWidget(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                CustomTextWidget(
                  'Join BiteFlow POS and start managing your restaurant today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ROW 1: FULL NAME & STORE NAME
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  context: context,
                  controller: controller.fullNameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  context: context,
                  controller: controller.storeNameController,
                  hintText: 'Restaurant / Store Name',
                  prefixIcon: Icons.storefront_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ROW 2: CREATE PIN (4 Digits)
          Obx(
            () => _buildInputField(
              context: context,
              controller: controller.pinController,
              hintText: 'Create PIN (4 digits)',
              prefixIcon: Icons.lock_outline_rounded,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: !controller.isPinVisible.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPinVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: controller.togglePinVisibility,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ROW 3: CONFIRM PIN (4 Digits)
          Obx(
            () => _buildInputField(
              context: context,
              controller: controller.confirmPinController,
              hintText: 'Confirm PIN (4 digits)',
              prefixIcon: Icons.lock_outline_rounded,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: !controller.isConfirmPinVisible.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPinVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: controller.toggleConfirmPinVisibility,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // TERMS & CONDITIONS CHECKBOX
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: controller.agreeToTerms.value,
                    onChanged: controller.toggleAgreeToTerms,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CustomTextWidget(
                        'I agree to the ',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      CustomTextWidget(
                        'Terms of Service',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      CustomTextWidget(
                        ' and ',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      CustomTextWidget(
                        'Privacy Policy',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ERROR MESSAGE DISPLAY
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox(height: 14);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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

          // CREATE ACCOUNT BUTTON
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: controller.createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const CustomTextWidget(
                'Create Account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ALREADY HAVE AN ACCOUNT? LOGIN (RELOCATED UNDER BUTTON)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextWidget(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
              InkWell(
                onTap: () => Get.offNamed(AppRoutes.login),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: CustomTextWidget(
                    'Login',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // FOOTER BRANDING
          Center(
            child: CustomTextWidget(
              'BiteFlow POS v1.0 · Fast · Simple · Reliable',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: colors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          counterText: '',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: colors.onSurfaceVariant,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: colors.surfaceContainerLow,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
