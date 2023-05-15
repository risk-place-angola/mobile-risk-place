import 'package:flutter/material.dart';

extension NavigationContext on BuildContext {
  navigateAnimateTo(Widget page,
      {bool replace = false, bool fullScreenDialog = false}) {
    return Navigator.of(this).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        fullscreenDialog: fullScreenDialog,
        pageBuilder: (context, animation, secondaryAnimation) => page,
      ),
    );
  }

  navigateToAndReplace(Widget page, {bool fullScreenDialog = false}) =>
      Navigator.of(this).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1500),
          fullscreenDialog: fullScreenDialog,
          pageBuilder: (context, animation, secondaryAnimation) => page,
        ),
      );
}
