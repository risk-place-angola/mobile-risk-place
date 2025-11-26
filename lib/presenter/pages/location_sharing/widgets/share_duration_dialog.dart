import 'package:flutter/material.dart';
import 'package:rpa/l10n/app_localizations.dart';

class ShareDurationDialog extends StatelessWidget {
  const ShareDurationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.shareLocationTitle ?? 'Share Location',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.shareLocationQuestion ?? 'How long do you want to share?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _DurationOption(
                  icon: Icons.access_time,
                  title: l10n?.minutes15 ?? '15 minutes',
                  subtitle: l10n?.shortSharing ?? 'Short sharing',
                  minutes: 15,
                  onTap: () => Navigator.pop(context, 15),
                ),
                const SizedBox(height: 12),
                _DurationOption(
                  icon: Icons.schedule,
                  title: l10n?.minutes30 ?? '30 minutes',
                  subtitle: l10n?.recommended ?? 'Recommended',
                  minutes: 30,
                  isRecommended: true,
                  onTap: () => Navigator.pop(context, 30),
                ),
                const SizedBox(height: 12),
                _DurationOption(
                  icon: Icons.timer,
                  title: l10n?.minutes60 ?? '60 minutes',
                  subtitle: l10n?.longSharing ?? 'Long sharing',
                  minutes: 60,
                  onTap: () => Navigator.pop(context, 60),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int minutes;
  final bool isRecommended;
  final VoidCallback onTap;

  const _DurationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.minutes,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          border: Border.all(
            color: isRecommended
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isRecommended
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRecommended
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isRecommended
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isRecommended
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Recomendado',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
