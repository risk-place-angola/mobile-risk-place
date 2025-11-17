import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Controller for managing the slide-out menu state
class MenuController extends ChangeNotifier {
  bool _isOpen = false;
  
  bool get isOpen => _isOpen;
  
  /// Open the menu with animation
  void openMenu() {
    _isOpen = true;
    notifyListeners();
  }
  
  /// Close the menu with animation
  void closeMenu() {
    _isOpen = false;
    notifyListeners();
  }
  
  /// Toggle menu state
  void toggleMenu() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}

/// Provider for menu controller
final menuControllerProvider = ChangeNotifierProvider<MenuController>((ref) {
  return MenuController();
});
