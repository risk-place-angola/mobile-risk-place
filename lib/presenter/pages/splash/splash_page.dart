import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/core/utils/navigator_handler.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _authController = ref.watch(authControllerProvider.notifier);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/rpa_logo.png',
            ),
          ).animate(
            effects: [
              const ScaleEffect(
                begin: Offset(0, 0),
                end: Offset(1.0, 1.0),
                curve: Curves.fastOutSlowIn,
                duration: Duration(seconds: 2),
              )
            ],
            onComplete: (controller) {
              _authController.initialize();

              Future.delayed(const Duration(seconds: 2), () {
                _authController.userStored != null
                    ? context.navigateToAndReplace(HomePage())
                    : context.navigateToAndReplace(const LoginPage());
              });
            },
          )
        ],
      ),
    );
  }
}
