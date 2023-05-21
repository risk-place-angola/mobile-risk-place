import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/presenter/controllers/warns.controller.dart';

mixin HomePageState implements ChangeNotifier {
  PageController pageController = PageController();
  int pageIndex = 0;

  void setNewAlert(WidgetRef ref) {
    ref.read(hasNewAlertNotifier.notifier).update((state) => !state);
    notifyListeners();
  }

  updateIndex(int index) {
    pageIndex = index;
    pageController.jumpToPage(index);
    notifyListeners();
  }
}

class HomeController extends ChangeNotifier with HomePageState {}

final homeProvider = ChangeNotifierProvider((ref) => HomeController());
