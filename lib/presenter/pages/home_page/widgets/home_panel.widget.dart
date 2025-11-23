import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/presenter/controllers/safe_route.controller.dart';
import 'package:rpa/presenter/pages/home_page/widgets/search_bar.widget.dart';
import 'package:rpa/presenter/pages/home_page/widgets/quick_action_button.widget.dart';
import 'package:rpa/presenter/pages/home_page/widgets/recent_section.widget.dart';
import 'package:rpa/presenter/pages/home_page/widgets/more_options_section.widget.dart';
import 'package:rpa/data/models/safe_place.model.dart';
import 'package:rpa/data/models/saved_address.dart';
import 'package:rpa/data/services/safe_places.service.dart';
import 'package:rpa/data/services/location_sharing.service.dart';
import 'package:rpa/data/services/profile.service.dart';
import 'package:rpa/presenter/pages/safe_places/widgets/add_safe_place_dialog.dart';
import 'package:rpa/presenter/pages/safe_places/saved_places.screen.dart';
import 'package:rpa/presenter/pages/emergency_services/emergency_services.screen.dart';
import 'package:rpa/presenter/pages/location_sharing/widgets/share_duration_dialog.dart';
import 'package:rpa/presenter/pages/location_sharing/share_location.screen.dart';
import 'package:rpa/presenter/pages/safe_route/safe_route_screen.dart';
import 'package:rpa/presenter/widgets/set_address_dialog.dart';
import 'package:unicons/unicons.dart';
import 'package:rpa/core/error/error_handler.dart';

class RiskPlaceHomePanel extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onVoiceSearchTap;

  const RiskPlaceHomePanel({
    Key? key,
    this.onSearchTap,
    this.onVoiceSearchTap,
  }) : super(key: key);

  @override
  ConsumerState<RiskPlaceHomePanel> createState() => _RiskPlaceHomePanelState();
}

class _RiskPlaceHomePanelState extends ConsumerState<RiskPlaceHomePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _dragStartPosition = 0;
  double _currentPanelHeight = 0;

  static const double _collapsedHeight = 100.0;
  static const double _mediumHeight = 240.0;
  static const double _expandedHeight = 600.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: _collapsedHeight, end: _expandedHeight)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _currentPanelHeight = _collapsedHeight;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanelDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition.dy;
  }

  void _onPanelDragUpdate(DragUpdateDetails details) {
    final controller = ref.read(homePanelControllerProvider);
    final delta = _dragStartPosition - details.globalPosition.dy;
    final newHeight = _currentPanelHeight + delta;

    if (newHeight >= _collapsedHeight && newHeight <= _expandedHeight) {
      setState(() {
        _currentPanelHeight = newHeight;
      });
      controller.updatePanelHeight(newHeight);
      _dragStartPosition = details.globalPosition.dy;

      if (_currentPanelHeight < (_collapsedHeight + _mediumHeight) / 2) {
        controller.collapsePanel();
      } else if (_currentPanelHeight < (_mediumHeight + _expandedHeight) / 2) {
        controller.setMediumPanel();
      } else {
        controller.expandPanel();
      }
    }
  }

  void _onPanelDragEnd(DragEndDetails details) {
    final controller = ref.read(homePanelControllerProvider);

    if (_currentPanelHeight < (_collapsedHeight + _mediumHeight) / 2) {
      _animateToHeight(_collapsedHeight);
      controller.collapsePanel();
    } else if (_currentPanelHeight < (_mediumHeight + _expandedHeight) / 2) {
      _animateToHeight(_mediumHeight);
      controller.setMediumPanel();
    } else {
      _animateToHeight(_expandedHeight);
      controller.expandPanel();
    }
  }

  void _animateToHeight(double targetHeight) {
    final controller = ref.read(homePanelControllerProvider);
    _animation = Tween<double>(
      begin: _currentPanelHeight,
      end: targetHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _currentPanelHeight = targetHeight;
      });
      controller.updatePanelHeight(targetHeight);
    });
  }

  Future<void> _handleQuickAction(String action) async {
    switch (action) {
      case 'home':
        await _handleNavigateHome();
        break;
      case 'work':
        await _handleNavigateWork();
        break;
      case 'add_place':
        await _handleAddSafePlace();
        break;
      case 'safe_route':
        await _handleSafeRoute();
        break;
    }
  }

  Future<void> _handleNavigateHome() async {
    final locationController = ref.read(locationControllerProvider);
    final homePanelController = ref.read(homePanelControllerProvider);

    if (!homePanelController.hasHomeAddress) {
      await _showSetAddressDialog(AddressType.home);
      return;
    }

    final currentPosition = locationController.currentPosition;
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguardando localização...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final profileService = ref.read(profileServiceProvider);
    final homeAddress = await profileService.getHomeAddress();

    if (homeAddress == null) {
      await _showSetAddressDialog(AddressType.home);
      return;
    }

    final safeRouteController = ref.read(safeRouteControllerProvider);
    await safeRouteController.calculateSafeRoute(
      origin: LatLng(currentPosition.latitude, currentPosition.longitude),
      destination: LatLng(homeAddress.latitude, homeAddress.longitude),
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SafeRouteScreen(),
        ),
      );
    }
  }

  Future<void> _handleNavigateWork() async {
    final locationController = ref.read(locationControllerProvider);
    final homePanelController = ref.read(homePanelControllerProvider);

    if (!homePanelController.hasWorkAddress) {
      await _showSetAddressDialog(AddressType.work);
      return;
    }

    final currentPosition = locationController.currentPosition;
    if (currentPosition == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.waitingLocation ?? 'Aguardando localização...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final profileService = ref.read(profileServiceProvider);
    final workAddress = await profileService.getWorkAddress();

    if (workAddress == null) {
      await _showSetAddressDialog(AddressType.work);
      return;
    }

    final safeRouteController = ref.read(safeRouteControllerProvider);
    await safeRouteController.calculateSafeRoute(
      origin: LatLng(currentPosition.latitude, currentPosition.longitude),
      destination: LatLng(workAddress.latitude, workAddress.longitude),
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SafeRouteScreen(),
        ),
      );
    }
  }

  Future<void> _showSetAddressDialog(AddressType addressType) async {
    final result = await showDialog<SavedAddress>(
      context: context,
      builder: (context) => SetAddressDialog(
        addressType: addressType,
      ),
    );

    if (result != null) {
      final homePanelController = ref.read(homePanelControllerProvider);
      if (addressType == AddressType.home) {
        homePanelController.setHomeAddress(result.address);
      } else {
        homePanelController.setWorkAddress(result.address);
      }

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addressType == AddressType.home
                ? (l10n?.homeAddressSavedSuccess ?? 'Endereço de casa salvo com sucesso!')
                : (l10n?.workAddressSavedSuccess ?? 'Endereço de trabalho salvo com sucesso!'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (addressType == AddressType.home) {
        await _handleNavigateHome();
      } else {
        await _handleNavigateWork();
      }
    }
  }

  Future<void> _handleSafeRoute() async {
    final locationController = ref.read(locationControllerProvider);

    if (locationController.currentPosition == null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.waitingGPS ?? 'Aguardando localização GPS...'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SafeRouteScreen(),
        ),
      );
    }
  }

  Future<void> _handleAddSafePlace() async {
    final result = await showDialog<SafePlace>(
      context: context,
      builder: (context) => const AddSafePlaceDialog(),
    );

    if (result != null && mounted) {
      try {
        final service = ref.read(safePlacesServiceProvider);
        await service.initialize();
        await service.createSafePlace(result);

        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((l10n?.addedSuccessfully ?? '{name} adicionado com sucesso!').toString().replaceAll('{name}', result.name)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  void _handleRecentItemTap(RecentItem item) {}

  Future<void> _handleShareLocation() async {
    final duration = await showDialog<int>(
      context: context,
      builder: (context) => const ShareDurationDialog(),
    );

    if (duration != null && mounted) {
      try {
        final locationController = ref.read(locationControllerProvider);
        final position = locationController.currentPosition;

        if (position == null) {
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.waitingGPS ?? 'Aguardando localização GPS...'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        final service = ref.read(locationSharingServiceProvider);
        final session = await service.createSession(
          durationMinutes: duration,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShareLocationScreen(
                session: session,
                durationMinutes: duration,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  void _handleMoreOptionTap(String option) async {
    switch (option) {
      case 'saved_places':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SavedPlacesScreen(),
          ),
        );
        break;
      case 'share_location':
        await _handleShareLocation();
        break;
      case 'safe_route':
        await _handleSafeRoute();
        break;
      case 'emergency_services':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmergencyServicesScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(homePanelControllerProvider);
    final panelState = controller.panelState;

    // Return empty container if hidden
    if (panelState == PanelState.hidden) {
      return const SizedBox.shrink();
    }

    // Sync animation with state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (panelState == PanelState.collapsed &&
          _currentPanelHeight != _collapsedHeight) {
        _animateToHeight(_collapsedHeight);
      } else if (panelState == PanelState.medium &&
          _currentPanelHeight != _mediumHeight) {
        _animateToHeight(_mediumHeight);
      } else if (panelState == PanelState.expanded &&
          _currentPanelHeight != _expandedHeight) {
        _animateToHeight(_expandedHeight);
      }
    });

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragStart: _onPanelDragStart,
        onVerticalDragUpdate: _onPanelDragUpdate,
        onVerticalDragEnd: _onPanelDragEnd,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final height = _animationController.isAnimating
                ? _animation.value
                : _currentPanelHeight;

            return Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      _buildDragHandle(),

                      // Search bar - Always visible
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: RiskPlaceSearchBar(
                          onTap: widget.onSearchTap,
                          //onMicTap: widget.onVoiceSearchTap, // Temporarily disabled voice search
                        ),
                      ),

                      // Quick actions - Show in medium and expanded states
                      if (height > _collapsedHeight) ...[
                        const SizedBox(height: 16),
                        QuickActionsRow(
                          actions: _buildQuickActions(context, controller),
                        ),
                      ],

                      // Show more content only when fully expanded
                      if (height > _mediumHeight) ...[
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Recent section
                        RecentSection(
                          recentItems: controller.recentItems,
                          onItemTap: _handleRecentItemTap,
                        ),

                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // More options
                        MoreOptionsSection(
                          onOptionTap: _handleMoreOptionTap,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  List<QuickActionData> _buildQuickActions(
    BuildContext context,
    HomePanelController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    return [
      QuickActionData(
        icon: UniconsLine.home,
        label: controller.homeAddress ?? (l10n?.home ?? 'Home'),
        iconColor: Colors.blue,
        onTap: () => _handleQuickAction('home'),
      ),
      QuickActionData(
        icon: UniconsLine.briefcase,
        label: controller.workAddress ?? (l10n?.work ?? 'Work'),
        iconColor: Colors.purple,
        onTap: () => _handleQuickAction('work'),
      ),
      QuickActionData(
        icon: UniconsLine.plus_circle,
        label: l10n?.addSafePlace ?? 'Add Safe Place',
        iconColor: Colors.green,
        onTap: () => _handleQuickAction('add_place'),
      ),
      QuickActionData(
        icon: UniconsLine.map_marker_shield,
        label: l10n?.safeRouteButton ?? 'Safe Route',
        iconColor: Colors.teal,
        onTap: () => _handleQuickAction('safe_route'),
      ),
    ];
  }
}
