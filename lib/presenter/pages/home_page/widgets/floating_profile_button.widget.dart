import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:unicons/unicons.dart';

/// Floating profile button that appears in the top-right corner
/// Similar to Waze's profile button
class FloatingProfileButton extends ConsumerWidget {
  final VoidCallback? onTap;

  const FloatingProfileButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).userStored;
    final userName = user?.name?.isNotEmpty == true 
        ? user!.name!.substring(0, 1).toUpperCase() 
        : 'U';

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: user != null
                ? Text(
                    userName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Icon(
                    UniconsLine.user,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}
