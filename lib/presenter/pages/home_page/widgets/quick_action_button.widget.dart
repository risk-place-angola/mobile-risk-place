import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBgColor =
        backgroundColor ?? effectiveIconColor.withOpacity(0.1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = constraints.maxWidth > 80 ? 64.0 : 56.0;
        final iconSize = constraints.maxWidth > 80 ? 32.0 : 28.0;
        final fontSize = constraints.maxWidth > 80 ? 12.0 : 11.0;
        
        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveIconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: buttonSize + 8,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  final List<QuickActionData> actions;

  const QuickActionsRow({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 8.0 : 16.0;
    final itemPadding = screenWidth < 360 ? 2.0 : 4.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((action) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: itemPadding),
              child: QuickActionButton(
                icon: action.icon,
                label: action.label,
                iconColor: action.iconColor,
                backgroundColor: action.backgroundColor,
                onTap: action.onTap,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class QuickActionData {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  QuickActionData({
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    required this.onTap,
  });
}
