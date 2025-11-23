import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:rpa/l10n/app_localizations.dart';

class RiskPlaceSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onMicTap;
  final bool enabled;
  final String? hintText;

  const RiskPlaceSearchBar({
    Key? key,
    this.onTap,
    this.onMicTap,
    this.enabled = true,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        return GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  UniconsLine.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    hintText ?? AppLocalizations.of(context)?.searchLocation ?? 'Search Location',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onMicTap != null) ...[
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  GestureDetector(
                    onTap: onMicTap,
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        UniconsLine.microphone,
                        color: Theme.of(context).colorScheme.primary,
                        size: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
