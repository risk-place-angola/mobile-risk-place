import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';
import 'package:rpa/presenter/pages/home_page/widgets/search_bar.widget.dart';
import 'package:rpa/presenter/pages/home_page/widgets/quick_action_button.widget.dart';
import 'package:rpa/presenter/pages/home_page/widgets/recent_section.widget.dart';
import 'package:rpa/presenter/pages/home_page/widgets/more_options_section.widget.dart';
import 'package:unicons/unicons.dart';

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

  // Panel heights - Waze-inspired
  static const double _collapsedHeight = 100.0;  // Only search bar visible
  static const double _mediumHeight = 240.0;     // Search + quick actions
  static const double _expandedHeight = 600.0;    // All content
  static const double _minHeight = 0.0;           // Hidden

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

    // Clamp height between min and max
    if (newHeight >= _minHeight && newHeight <= _expandedHeight) {
      setState(() {
        _currentPanelHeight = newHeight;
      });
      _dragStartPosition = details.globalPosition.dy;

      // Update controller state based on height thresholds
      if (_currentPanelHeight < _collapsedHeight / 2) {
        controller.hidePanel();
      } else if (_currentPanelHeight < (_collapsedHeight + _mediumHeight) / 2) {
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
    
    // Snap to nearest state based on position
    if (_currentPanelHeight < _collapsedHeight / 2) {
      _animateToHeight(_minHeight);
      controller.hidePanel();
    } else if (_currentPanelHeight < (_collapsedHeight + _mediumHeight) / 2) {
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
    });
  }

  void _handleQuickAction(String action) {
    // TODO: Implement quick action handlers
    print('Quick action tapped: $action');
  }

  void _handleRecentItemTap(RecentItem item) {
    // TODO: Implement recent item handler
    print('Recent item tapped: ${item.title}');
  }

  void _handleMoreOptionTap(String option) {
    // TODO: Implement more options handlers
    print('More option tapped: $option');
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
      if (panelState == PanelState.collapsed && _currentPanelHeight != _collapsedHeight) {
        _animateToHeight(_collapsedHeight);
      } else if (panelState == PanelState.medium && _currentPanelHeight != _mediumHeight) {
        _animateToHeight(_mediumHeight);
      } else if (panelState == PanelState.expanded && _currentPanelHeight != _expandedHeight) {
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
                          onMicTap: widget.onVoiceSearchTap,
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
    return [
      QuickActionData(
        icon: UniconsLine.home,
        label: controller.homeAddress ?? 'Home',
        iconColor: Colors.blue,
        onTap: () => _handleQuickAction('home'),
      ),
      QuickActionData(
        icon: UniconsLine.briefcase,
        label: controller.workAddress ?? 'Work',
        iconColor: Colors.purple,
        onTap: () => _handleQuickAction('work'),
      ),
      QuickActionData(
        icon: UniconsLine.plus_circle,
        label: 'Add Safe Place',
        iconColor: Colors.green,
        onTap: () => _handleQuickAction('add_place'),
      ),
      QuickActionData(
        icon: UniconsLine.exclamation_triangle,
        label: 'Report Incident',
        iconColor: Colors.red,
        onTap: () => _handleQuickAction('report'),
      ),
    ];
  }
}
