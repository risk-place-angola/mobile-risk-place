import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/providers/repository_providers.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';
import 'package:rpa/core/utils/navigator_handler.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider.notifier);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/maka_splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/maka_logo.png',
            width: 200,
            height: 200,
          ).animate(
            effects: [
              const ScaleEffect(
                begin: Offset(0, 0),
                end: Offset(1.0, 1.0),
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 1200),
              )
            ],
            onComplete: (controller) async {
              await _ensureAuthenticationState(authController);
              
              if (mounted) {
                context.navigateToAndReplace(const HomePage());
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _ensureAuthenticationState(AuthController authController) async {
    if (!AuthTokenManager().hasToken) {
      log('Token not in memory, loading from storage', name: 'SplashPage');
      await authController.initialize();
    } else {
      log('Token already loaded in memory', name: 'SplashPage');
    }
  }
}
