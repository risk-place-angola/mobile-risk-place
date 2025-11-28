import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double size;
  final double borderWidth;
  final bool isAnonymous;

  const UserAvatar({
    super.key,
    required this.userId,
    this.size = 56,
    this.borderWidth = 3,
    this.isAnonymous = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnonymous) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFF39C12),
            width: borderWidth,
          ),
        ),
        child: ClipOval(
          child: SvgPicture.asset(
            'assets/avatars/neter_guardian.svg',
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF3498DB),
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/avatars/neter_member.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
