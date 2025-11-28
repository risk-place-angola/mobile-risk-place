import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/core/services/permission_service.dart';
import 'package:rpa/core/services/fcm_service.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/presenter/pages/menu/widgets/menu_item.widget.dart';
import 'package:rpa/presenter/pages/menu/widgets/notification_card.widget.dart';
import 'package:rpa/presenter/pages/reports/all_reports_screen.dart';
import 'package:rpa/presenter/pages/emergency_contacts/emergency_contacts_screen.dart';
import 'package:rpa/presenter/pages/my_alerts/my_alerts_screen.dart';
import 'package:rpa/presenter/pages/safety_settings/safety_settings_screen.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/presenter/widgets/user_avatar.widget.dart';
import 'package:unicons/unicons.dart';

/// Waze-style slide-out menu drawer
class SlideOutMenu extends ConsumerWidget {
  final VoidCallback onClose;

  const SlideOutMenu({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).userStored;
    final userId = user?.id;
    final isLoggedIn = userId != null && userId.isNotEmpty;
    final userName = user?.name ?? 'Visitante';
    final userInitial = isLoggedIn && userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : 'V';

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF121212),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(
                context, ref, userName, userInitial, isLoggedIn, userId),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  MenuItem(
                    icon: UniconsLine.exclamation_triangle,
                    title:
                        AppLocalizations.of(context)?.myAlerts ?? 'My Alerts',
                    subtitle: AppLocalizations.of(context)
                            ?.viewAlertsPostedOrSubscribed ??
                        'View alerts you posted or subscribed to',
                    onTap: () => _handleMyAlerts(context),
                    iconColor: Colors.orange,
                  ),
                  MenuItem(
                    icon: UniconsLine.list_ul,
                    title: AppLocalizations.of(context)?.allReports ??
                        'All Reports',
                    subtitle:
                        AppLocalizations.of(context)?.viewAllSystemReports ??
                            'View all system reports',
                    onTap: () => _handleAllReports(context),
                    iconColor: Colors.deepPurple,
                  ),
                  MenuItem(
                    icon: UniconsLine.phone,
                    title:
                        AppLocalizations.of(context)?.emergencyContactsTitle ??
                            'Emergency Contacts',
                    subtitle:
                        AppLocalizations.of(context)?.manageTrustedContacts ??
                            'Manage trusted contacts',
                    onTap: () => _handleEmergencyContacts(context),
                    iconColor: Colors.blue,
                  ),
                  MenuItem(
                    icon: UniconsLine.shield_check,
                    title: AppLocalizations.of(context)?.safetySettingsTitle ??
                        'Safety Settings',
                    subtitle: AppLocalizations.of(context)
                            ?.notificationsTrackingPrivacy ??
                        'Notifications, tracking, privacy',
                    onTap: () => _handleSafetySettings(context),
                    iconColor: Colors.teal,
                  ),
                  MenuItem(
                    icon: UniconsLine.comment_dots,
                    title: AppLocalizations.of(context)?.communityFeedback ??
                        'Community & Feedback',
                    subtitle:
                        AppLocalizations.of(context)?.sendFeedbackReadUpdates ??
                            'Send feedback or read updates',
                    onTap: () => _handleMenuTap('community', context),
                    iconColor: Colors.purple,
                  ),
                  MenuItem(
                    icon: UniconsLine.user,
                    title:
                        AppLocalizations.of(context)?.myProfile ?? 'My Profile',
                    subtitle: AppLocalizations.of(context)
                            ?.editPersonalInfoPreferences ??
                        'Edit personal info & preferences',
                    onTap: () => _handleMenuTap('profile', context),
                    iconColor: Colors.indigo,
                  ),
                ],
              ),
            ),

            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String userName,
    String userInitial,
    bool isLoggedIn,
    String? userId,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                userId: isLoggedIn
                    ? userId ?? 'default'
                    : ref.read(anonymousUserManagerProvider).deviceId ??
                        'default',
                size: 56,
                borderWidth: 2,
                isAnonymous: !isLoggedIn,
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isLoggedIn
                ? (AppLocalizations.of(context)?.helloUser(userName) ??
                    'Olá, $userName!')
                : (AppLocalizations.of(context)?.welcomeNeter ??
                    'Welcome, Neter!'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Login or View Profile Button
          if (!isLoggedIn)
            ElevatedButton.icon(
              onPressed: () => _handleLogin(context),
              icon: const Icon(Icons.login),
              label: Text(AppLocalizations.of(context)?.loginOrRegister ??
                  'Login / Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          else
            OutlinedButton(
              onPressed: () => _handleMenuTap('profile', context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                AppLocalizations.of(context)?.viewProfile ?? 'View Profile',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    const appVersion = 'v1.0.0';

    return FutureBuilder<bool>(
      future: ref.read(permissionServiceProvider).checkNotificationPermission(),
      builder: (context, snapshot) {
        final hasPermission = snapshot.data ?? false;

        return Column(
          children: [
            if (!hasPermission)
              NotificationPermissionCard(
                onEnableTap: () => _handleEnableNotifications(ref),
              ),

            // App Version
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                appVersion,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuTap(String action, BuildContext context) {
    onClose();
    log('Menu action: $action', name: 'SlideOutMenu');

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.featureComingSoon ??
            'This feature will be available soon. Stay tuned for updates!'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n?.close ?? 'Close',
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleEmergencyContacts(BuildContext context) {
    onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyContactsScreen(),
      ),
    );
  }

  Future<void> _handleEnableNotifications(WidgetRef ref) async {
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final hasPermission =
          await permissionService.checkNotificationPermission();

      if (hasPermission) {
        log('Notifications already enabled', name: 'SlideOutMenu');
        return;
      }

      // Tentar solicitar permissão
      await permissionService.requestNotificationPermission();

      // Verificar novamente após solicitar
      final granted = await permissionService.checkNotificationPermission();

      if (granted) {
        // Se concedida, inicializar FCM
        final fcmService = FCMService();
        await fcmService.initialize();
        log('Notification setup completed', name: 'SlideOutMenu');
      } else {
        // Se negada, abrir configurações
        log('Permission denied, opening settings', name: 'SlideOutMenu');
        await permissionService.openSettings();
      }
    } catch (e) {
      log('Error enabling notifications: $e', name: 'SlideOutMenu');
    }
  }

  void _handleLogin(BuildContext context) {
    onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _handleAllReports(BuildContext context) {
    onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllReportsScreen(),
      ),
    );
  }

  void _handleMyAlerts(BuildContext context) {
    onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyAlertsScreen(),
      ),
    );
  }

  void _handleSafetySettings(BuildContext context) {
    onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafetySettingsScreen(),
      ),
    );
  }
}
