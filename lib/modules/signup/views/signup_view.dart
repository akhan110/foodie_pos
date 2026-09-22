import 'package:flutter/material.dart';
import 'package:foodiepos/modules/signup/controllers/signup_controller.dart';
import 'package:foodiepos/modules/signup/widgets/signup_form_card.dart';
import 'package:foodiepos/modules/signup/widgets/signup_hero_section.dart';
import 'package:get/get.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 900;

          if (isSmallScreen) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: const SignupFormCard(),
                ),
              ),
            );
          }

          return Row(
            children: [
              // =========================================================
              // LEFT SIDE (Hero / Branding Banner)
              // =========================================================
              const Expanded(
                flex: 10,
                child: SizedBox(
                  height: double.infinity,
                  child: SignupHeroSection(),
                ),
              ),

              // =========================================================
              // RIGHT SIDE (Form Card)
              // =========================================================
              Expanded(
                flex: 12,
                child: Container(
                  height: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: const SignupFormCard(),
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
}
