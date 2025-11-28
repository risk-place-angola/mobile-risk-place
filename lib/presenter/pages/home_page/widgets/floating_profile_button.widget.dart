import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/presenter/widgets/user_avatar.widget.dart';

class FloatingProfileButton extends ConsumerWidget {
  final VoidCallback? onTap;

  const FloatingProfileButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).userStored;
    final userId = user?.id;
    final isLoggedIn = userId != null && userId.isNotEmpty;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: UserAvatar(
            userId: isLoggedIn
                ? userId
                : ref.read(anonymousUserManagerProvider).deviceId ?? 'default',
            size: 48,
            borderWidth: 2,
            isAnonymous: !isLoggedIn,
          ),
        ),
      ),
    );
  }
}
