import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlertButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData? icon;

  const AlertButton({super.key, this.onPressed, this.icon});

  @override
  State<AlertButton> createState() => _AlertButtonState();
}

class _AlertButtonState extends State<AlertButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {},
      onLongPressEnd: (details) {},
      onTap: widget.onPressed,
      child: _HaloItem(
        radius: 35,
        icon: widget.icon,
        child: _HaloItem(
          radius: 50,
          child: _HaloItem(
            radius: 40,
          ),
        ),
      ),
    );
  }
}

class _HaloItem extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? radius;
  final Widget? child;

  const _HaloItem(
      {this.child, super.key, this.icon, this.onPressed, this.radius});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CircleAvatar(
              minRadius: radius,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(radius! >= 50
                      ? 0.5
                      : radius! >= 35
                          ? 1.0
                          : 0.2),
              child: child != null && icon != null
                  ? Icon(
                      icon,
                      color: Colors.white,
                      size: 35,
                    )
                  : null)
          .animate(
        effects: [
          const FadeEffect(
            begin: 0,
            end: 8,
            curve: Curves.fastOutSlowIn,
            duration: Duration(seconds: 2),
          )
        ],
      ),
    ]);
  }
}
