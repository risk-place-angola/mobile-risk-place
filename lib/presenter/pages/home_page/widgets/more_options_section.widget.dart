import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:rpa/l10n/app_localizations.dart';

class MoreOptionsSection extends StatelessWidget {
  final Function(String) onOptionTap;

  const MoreOptionsSection({
    Key? key,
    required this.onOptionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            l10n?.moreOptions ?? 'More Options',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _OptionTile(
          icon: UniconsLine.bookmark,
          iconColor: Colors.purple,
          title: l10n?.savedPlaces ?? 'Saved Places',
          subtitle: l10n?.savedPlacesSubtitle ?? 'Quick access to your locations',
          onTap: () => onOptionTap('saved_places'),
        ),
        _OptionTile(
          icon: UniconsLine.location_arrow,
          iconColor: Colors.green,
          title: l10n?.shareMyLocation ?? 'Share My Location',
          subtitle: l10n?.shareMyLocationSubtitle ?? 'Send location to family & friends',
          onTap: () => onOptionTap('share_location'),
        ),
        _OptionTile(
          icon: UniconsLine.shield_check,
          iconColor: Colors.teal,
          title: l10n?.checkSafeRoute ?? 'Check Safe Route',
          subtitle: l10n?.checkSafeRouteSubtitle ?? 'Find the safest path',
          onTap: () => onOptionTap('safe_route'),
        ),
        _OptionTile(
          icon: UniconsLine.phone_volume,
          iconColor: Colors.red,
          title: l10n?.emergencyServices ?? 'Emergency Services',
          subtitle: l10n?.emergencyServicesSubtitle ?? 'Call 112 / Police / Firefighters',
          onTap: () => onOptionTap('emergency_services'),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 20,
          vertical: isSmallScreen ? 8 : 12,
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 44 : 48,
              height: isSmallScreen ? 44 : 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isSmallScreen ? 14 : 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
