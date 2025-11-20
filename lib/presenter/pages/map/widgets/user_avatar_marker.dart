import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatarMarker extends StatelessWidget {
  final String avatarId;
  final Color color;
  final double size;
  final bool isMoving;

  const UserAvatarMarker({
    super.key,
    required this.avatarId,
    required this.color,
    this.size = 40,
    this.isMoving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/avatars/$avatarId.svg',
                width: size - 16,
                height: size - 16,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        if (isMoving)
          Positioned(
            bottom: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AnimatedUserAvatarMarker extends StatefulWidget {
  final String avatarId;
  final Color color;
  final double size;
  final bool isMoving;

  const AnimatedUserAvatarMarker({
    super.key,
    required this.avatarId,
    required this.color,
    this.size = 32,
    this.isMoving = false,
  });

  @override
  State<AnimatedUserAvatarMarker> createState() => _AnimatedUserAvatarMarkerState();
}

class _AnimatedUserAvatarMarkerState extends State<AnimatedUserAvatarMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: UserAvatarMarker(
          avatarId: widget.avatarId,
          color: widget.color,
          size: widget.size,
          isMoving: widget.isMoving,
        ),
      ),
    );
  }
}
