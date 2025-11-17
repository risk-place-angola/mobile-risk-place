import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/presenter/pages/menu/widgets/menu_item.widget.dart';
import 'package:rpa/presenter/pages/menu/widgets/notification_card.widget.dart';
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
            _buildHeader(context, ref, userName, userInitial, isLoggedIn),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  MenuItem(
                    icon: UniconsLine.exclamation_triangle,
                    title: 'My Alerts',
                    subtitle: 'View alerts you posted or subscribed to',
                    onTap: () => _handleMenuTap('my_alerts'),
                    iconColor: Colors.orange,
                  ),
                  MenuItem(
                    icon: UniconsLine.map_marker,
                    title: 'Nearby Incidents',
                    subtitle: 'Real-time danger zones around you',
                    onTap: () => _handleMenuTap('nearby_incidents'),
                    iconColor: Colors.red,
                  ),
                  MenuItem(
                    icon: UniconsLine.plus_circle,
                    title: 'Report an Incident',
                    subtitle: 'Submit a new safety alert',
                    onTap: () => _handleMenuTap('report_incident'),
                    iconColor: Colors.green,
                  ),
                  MenuItem(
                    icon: UniconsLine.phone,
                    title: 'Emergency Contacts',
                    subtitle: 'Manage trusted contacts',
                    onTap: () => _handleMenuTap('emergency_contacts'),
                    iconColor: Colors.blue,
                  ),
                  MenuItem(
                    icon: UniconsLine.shield_check,
                    title: 'Safety Settings',
                    subtitle: 'Notifications, tracking, privacy',
                    onTap: () => _handleMenuTap('safety_settings'),
                    iconColor: Colors.teal,
                  ),
                  MenuItem(
                    icon: UniconsLine.comment_dots,
                    title: 'Community & Feedback',
                    subtitle: 'Send feedback or read updates',
                    onTap: () => _handleMenuTap('community'),
                    iconColor: Colors.purple,
                  ),
                  MenuItem(
                    icon: UniconsLine.user,
                    title: 'My Profile',
                    subtitle: 'Edit personal info & preferences',
                    onTap: () => _handleMenuTap('profile'),
                    iconColor: Colors.indigo,
                  ),
                ],
              ),
            ),
            
            // Footer Section
            _buildFooter(context),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isLoggedIn ? Icons.person : Icons.person_outline,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              // Close button
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
          // Greeting
          Text(
            isLoggedIn ? 'Olá, $userName!' : 'Bem-vindo!',
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
              label: const Text('Entrar / Registrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          else
            OutlinedButton(
              onPressed: () => _handleMenuTap('profile'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Ver perfil',
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

  Widget _buildFooter(BuildContext context) {
    const appVersion = 'v1.0.0'; // TODO: Get from package_info_plus
    
    return Column(
      children: [
        // Notification Permission Card
        NotificationPermissionCard(
          onEnableTap: _handleEnableNotifications,
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
  }

  void _handleMenuTap(String action) {
    onClose();
    print('Menu action: $action');
  }

  void _handleEnableNotifications() {
    print('Enable notifications tapped');
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
}
