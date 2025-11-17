import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Enum representing the different states of the home panel
enum PanelState {
  collapsed, // Only search bar visible (Waze-like collapsed state)
  medium,    // Search bar + quick actions visible
  expanded,  // Full view with all options
  hidden,    // Completely hidden (e.g., when viewing marker details)
}

/// Model for recent search items
class RecentItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime timestamp;
  final RecentItemType type;

  RecentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.timestamp,
    required this.type,
  });
}

enum RecentItemType {
  neighborhood,
  incident,
  safeRoute,
  location,
}

/// Controller for managing home panel state
class HomePanelController extends ChangeNotifier {
  PanelState _panelState = PanelState.collapsed;
  List<RecentItem> _recentItems = [];
  String? _homeAddress;
  String? _workAddress;
  bool _isSearchFocused = false;

  PanelState get panelState => _panelState;
  List<RecentItem> get recentItems => _recentItems;
  String? get homeAddress => _homeAddress;
  String? get workAddress => _workAddress;
  bool get isSearchFocused => _isSearchFocused;

  /// Toggle between panel states
  void togglePanel() {
    if (_panelState == PanelState.collapsed) {
      _panelState = PanelState.medium;
    } else if (_panelState == PanelState.medium) {
      _panelState = PanelState.expanded;
    } else if (_panelState == PanelState.expanded) {
      _panelState = PanelState.collapsed;
    }
    notifyListeners();
  }
  
  /// Set panel to medium state (search + actions)
  void setMediumPanel() {
    _panelState = PanelState.medium;
    notifyListeners();
  }

  /// Set specific panel state
  void setPanelState(PanelState newState) {
    _panelState = newState;
    notifyListeners();
  }

  /// Hide panel (e.g., when showing marker details)
  void hidePanel() {
    _panelState = PanelState.hidden;
    notifyListeners();
  }

  /// Show panel in collapsed state
  void showPanel() {
    _panelState = PanelState.collapsed;
    notifyListeners();
  }

  /// Expand panel
  void expandPanel() {
    _panelState = PanelState.expanded;
    notifyListeners();
  }

  /// Collapse panel
  void collapsePanel() {
    _panelState = PanelState.collapsed;
    notifyListeners();
  }

  /// Add a recent item
  void addRecentItem(RecentItem item) {
    _recentItems = [item, ..._recentItems]
        .take(10) // Keep only last 10 items
        .toList();
    notifyListeners();
  }

  /// Clear recent items
  void clearRecentItems() {
    _recentItems = [];
    notifyListeners();
  }

  /// Set home address
  void setHomeAddress(String? address) {
    _homeAddress = address;
    notifyListeners();
  }

  /// Set work address
  void setWorkAddress(String? address) {
    _workAddress = address;
    notifyListeners();
  }

  /// Set search focus state
  void setSearchFocus(bool focused) {
    _isSearchFocused = focused;
    notifyListeners();
  }
}

/// Provider for home panel controller
final homePanelControllerProvider =
    ChangeNotifierProvider<HomePanelController>((ref) {
  return HomePanelController();
});
