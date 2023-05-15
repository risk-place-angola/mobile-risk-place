import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin HomePageState implements ChangeNotifier {
  PageController pageController = PageController();
  int pageIndex = 0;
  updateIndex(int index) {
    pageIndex = index;
    pageController.jumpToPage(index);
    notifyListeners();
  }
}

class HomeController extends ChangeNotifier with HomePageState {}

final homeProvider = ChangeNotifierProvider((ref) => HomeController());
