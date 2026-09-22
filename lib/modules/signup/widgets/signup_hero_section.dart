import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';

class SignupHeroSection extends StatelessWidget {
  const SignupHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFFF8F3);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOGO & TAGLINE
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 46,
                child: SvgPicture.asset(
                  isDark
                      ? 'assets/svg/biteflow_logo_dark.svg'
                      : 'assets/svg/biteflow_logo.svg',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // MAIN HEADLINE
            CustomTextWidget(
              'Start your\nBiteFlow journey.',
              style: TextStyle(
                fontSize: 38,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 12),

            // SUBTITLE
            CustomTextWidget(
              'Create your account and get your fast-food business running in minutes.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 28),

            // 3 FEATURE BULLETS
            _FeatureRow(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFFF8A00),
              iconBg: isDark
                  ? const Color(0xFF332011)
                  : const Color(0xFFFFEAD5),
              title: 'Quick Setup',
              subtitle: 'Get started in minutes',
              colors: colors,
            ),
            const SizedBox(height: 16),

            _FeatureRow(
              icon: Icons.bar_chart_rounded,
              iconColor: const Color(0xFF12B76A),
              iconBg: isDark
                  ? const Color(0xFF10281D)
                  : const Color(0xFFD1FADF),
              title: 'Built for Fast-Food',
              subtitle: 'Simple and powerful',
              colors: colors,
            ),
            const SizedBox(height: 16),

            _FeatureRow(
              icon: Icons.people_outline_rounded,
              iconColor: const Color(0xFF2E90FA),
              iconBg: isDark
                  ? const Color(0xFF122238)
                  : const Color(0xFFD1E9FF),
              title: 'Grow Your Business',
              subtitle: 'Serve more, do more',
              colors: colors,
            ),

            const SizedBox(height: 32),

            // BURGER ILLUSTRATION & MOTTO
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial warm glow in dark mode
                      if (isDark)
                        Container(
                          width: 220,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                      // Burger vector illustration
                      SizedBox(
                        height: 150,
                        child: SvgPicture.asset(
                          'assets/svg/hero_burger.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // HANDWRITTEN MOTTO
                  Transform.rotate(
                    angle: -0.05,
                    child: Column(
                      children: [
                        Text(
                          'Good Food',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFFF8A00),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Brings People Together',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFFF8A00),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              CustomTextWidget(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
