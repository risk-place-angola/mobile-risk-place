import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MoreOptionsSection extends StatelessWidget {
  final Function(String) onOptionTap;

  const MoreOptionsSection({
    Key? key,
    required this.onOptionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'More Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _OptionTile(
          icon: UniconsLine.bookmark,
          iconColor: Colors.purple,
          title: 'Saved Places',
          subtitle: 'Quick access to your locations',
          onTap: () => onOptionTap('saved_places'),
        ),
        _OptionTile(
          icon: UniconsLine.users_alt,
          iconColor: Colors.blue,
          title: 'Emergency Contacts',
          subtitle: 'Manage trusted contacts',
          onTap: () => onOptionTap('emergency_contacts'),
        ),
        _OptionTile(
          icon: UniconsLine.location_arrow,
          iconColor: Colors.green,
          title: 'Share My Location',
          subtitle: 'Send location to family & friends',
          onTap: () => onOptionTap('share_location'),
        ),
        _OptionTile(
          icon: UniconsLine.shield_check,
          iconColor: Colors.teal,
          title: 'Check Safe Route',
          subtitle: 'Find the safest path',
          onTap: () => onOptionTap('safe_route'),
        ),
        _OptionTile(
          icon: UniconsLine.history_alt,
          iconColor: Colors.orange,
          title: 'Incident History',
          subtitle: 'View past reports',
          onTap: () => onOptionTap('incident_history'),
        ),
        _OptionTile(
          icon: UniconsLine.phone_volume,
          iconColor: Colors.red,
          title: 'Emergency Services',
          subtitle: 'Call 112 / Police / Firefighters',
          onTap: () => onOptionTap('emergency_services'),
        ),
        _OptionTile(
          icon: UniconsLine.calendar_alt,
          iconColor: Colors.indigo,
          title: 'Connect Calendar',
          subtitle: 'Check event safety',
          onTap: () => onOptionTap('calendar'),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
