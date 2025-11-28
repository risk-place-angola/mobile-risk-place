import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/controllers/home.controller.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/data/providers/repository_providers.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/presenter/widgets/user_avatar.widget.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  User? _userStored;

  Future<void> _getStoredUser() async {
    ref.read(authControllerProvider).updateUser();
    setState(() {});
  }

  @override
  void initState() {
    _getStoredUser();
    super.initState();
  }

  bool get _isAuthenticated {
    final hasToken = AuthTokenManager().hasToken;
    final userId = _userStored?.id;
    return hasToken && userId != null && userId.isNotEmpty;
  }

  // Responsive helpers
  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 16; // Small phones
    if (width < 400) return 20; // Normal phones
    return 24; // Large phones & tablets
  }

  double _getResponsiveAvatarRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 50; // Small phones
    if (width < 400) return 55; // Normal phones
    return 60; // Large phones & tablets
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 375; // Base width (iPhone SE)
    return (baseSize * scale).clamp(baseSize * 0.85, baseSize * 1.15);
  }

  @override
  Widget build(BuildContext context) {
    _userStored = ref.watch(authControllerProvider).userStored;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.myProfileTitle ?? 'My Profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isAuthenticated
          ? _buildAuthenticatedProfile(context)
          : _buildAnonymousProfile(context),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context) {
    final padding = _getResponsivePadding(context);
    final avatarRadius = _getResponsiveAvatarRadius(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.8,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600, // Max width for tablets
        ),
        child: Column(
          children: [
            SizedBox(height: screenWidth < 360 ? 12 : 20),
            UserAvatar(
              userId: _userStored?.id ?? 'default',
              size: avatarRadius * 2,
              borderWidth: screenWidth < 360 ? 2.5 : 3,
            ),
            const SizedBox(height: 32),
            _InfoCard(
              icon: Icons.person_outline,
              label: AppLocalizations.of(context)?.name ?? 'Name',
              value: _userStored?.name ??
                  (AppLocalizations.of(context)?.notInformed ?? 'Not informed'),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.email_outlined,
              label: AppLocalizations.of(context)?.email ?? 'Email',
              value: _userStored?.email ??
                  (AppLocalizations.of(context)?.notInformed ?? 'Not informed'),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.phone_outlined,
              label: AppLocalizations.of(context)?.phone ?? 'Phone',
              value: _userStored?.phoneNumber ??
                  (AppLocalizations.of(context)?.notInformed ?? 'Not informed'),
            ),
            SizedBox(height: screenWidth < 360 ? 24 : 32),
            SizedBox(
              width: double.infinity,
              height: screenWidth < 360 ? 50 : 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(screenWidth < 360 ? 14 : 16),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 16 : 20,
                  ),
                ),
                icon: Icon(
                  Icons.edit_outlined,
                  size: screenWidth < 360 ? 18 : 20,
                ),
                label: Text(
                  AppLocalizations.of(context)?.editProfile ?? 'Edit Profile',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming Soon'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 12 : 16),
            SizedBox(
              width: double.infinity,
              height: screenWidth < 360 ? 50 : 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(screenWidth < 360 ? 14 : 16),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 16 : 20,
                  ),
                ),
                icon: Icon(
                  Icons.logout,
                  size: screenWidth < 360 ? 18 : 20,
                ),
                label: Text(
                  AppLocalizations.of(context)?.logout ?? 'Logout',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                  ref.read(homeProvider.notifier).pageIndex = 0;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: padding),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousProfile(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padding = _getResponsivePadding(context);
    final avatarRadius = _getResponsiveAvatarRadius(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.8,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600, // Max width for tablets
        ),
        child: Column(
          children: [
            SizedBox(height: isSmallScreen ? 12 : 20),
            UserAvatar(
              userId:
                  ref.read(anonymousUserManagerProvider).deviceId ?? 'default',
              size: avatarRadius * 2,
              borderWidth: isSmallScreen ? 2.5 : 3,
              isAnonymous: true,
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            // Saudação Neter
            Text(
              l10n?.helloNeter ?? 'Olá, Neter!',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 28),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
              child: Text(
                l10n?.exploringAsVisitor ??
                    'Você está explorando como visitante',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 32),
            // Card de informações do modo anônimo
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                border: Border.all(
                  color: const Color(0xFFF39C12).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF39C12).withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(isSmallScreen ? 10 : 12),
                        ),
                        child: Icon(
                          Icons.public,
                          color: const Color(0xFFF39C12),
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Text(
                          l10n?.anonymousMode ?? 'Modo Anônimo',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF39C12),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    l10n?.asNeterYouCan ?? 'Como Neter, você pode:',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildFeatureItem(
                    context,
                    Icons.notifications_active,
                    l10n?.viewNearbyAlerts ?? 'Ver alertas próximos',
                    true,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildFeatureItem(
                    context,
                    Icons.notifications,
                    l10n?.receiveNotifications ?? 'Receber notificações',
                    true,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    l10n?.createAccountToUnlock ??
                        'Crie sua conta para desbloquear:',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildFeatureItem(
                    context,
                    Icons.report_problem,
                    l10n?.reportAlerts ?? 'Reportar alertas',
                    false,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildFeatureItem(
                    context,
                    Icons.comment,
                    l10n?.commentAndInteract ?? 'Comentar e interagir',
                    false,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  _buildFeatureItem(
                    context,
                    Icons.person,
                    l10n?.customizeProfile ?? 'Personalizar seu perfil',
                    false,
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 32),
            // Botão CTA para criar conta
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 50 : 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF39C12),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 14 : 16),
                  ),
                  elevation: 4,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                  ),
                ),
                icon: Icon(
                  Icons.rocket_launch,
                  size: isSmallScreen ? 20 : 24,
                ),
                label: Text(
                  l10n?.createAccountOrLogin ?? 'Criar Conta / Login',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
              child: Text(
                l10n?.joinNeterCommunity ?? 'Junte-se à comunidade de Neters!',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: padding),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, IconData icon, String text, bool isEnabled) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      children: [
        Icon(
          isEnabled ? Icons.check_circle : Icons.lock,
          color: isEnabled ? Colors.green : Colors.white.withOpacity(0.3),
          size: isSmallScreen ? 18 : 20,
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final scale = screenWidth / 375;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF39C12),
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: (12 * scale).clamp(11.0, 13.0),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (16 * scale).clamp(14.0, 17.0),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
