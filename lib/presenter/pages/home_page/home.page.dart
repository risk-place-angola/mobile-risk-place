import 'dart:async';
import 'dart:developer';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rpa/core/utils/navigator_handler.dart';
import 'package:rpa/presenter/controllers/home.controller.dart';
import 'package:rpa/presenter/pages/alert_page.dart';
import 'package:rpa/presenter/pages/profile/profile.view.dart';
import 'package:unicons/unicons.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  RecorderController _controller = RecorderController();
  Timer? _timer;

  void _requestPermissionIfNecessary() async {
    await _controller.checkPermission();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      log('Microphone permission not granted');
      await Permission.microphone.request();
    }
  }

  Future<void> _toogleRecord() async {
    if (_controller.isRecording) {
      _controller.stop();
      setState(() {});
    } else {
      await _controller.record();
      setState(() {});
    }
  }

  handleNavigation() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print(timer.tick);
      if (timer.tick == 4) {
        context.navigateAnimateTo(AlertPage(), fullScreenDialog: true);
      }
      if (timer.tick >= 4) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavigation(
          pageIndex: ref.watch(homeProvider).pageIndex,
          updateIndex: ref.read(homeProvider).updateIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onLongPressEnd: (details) => _timer!.cancel(),
        onLongPress: () => handleNavigation(),
        child: FloatingActionButton(
          heroTag: "warning",
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: null,
          child: const Icon(
            UniconsThinline.exclamation_triangle,
            color: Colors.white,
          ),
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: ref.read(homeProvider).updateIndex,
        controller: ref.read(homeProvider).pageController,
        children: [
          MainPage(),
          ProfileView(),
        ],
      ),
    );
  }
}

class _BottomNavigation extends ConsumerWidget {
  Function(int)? updateIndex;
  int? pageIndex;
  _BottomNavigation(
      {Key? key, required this.pageIndex, required this.updateIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.read(homeProvider);
    return BottomNavigationBar(
      onTap: updateIndex,
      currentIndex: pageIndex!,
      backgroundColor: Theme.of(context).colorScheme.background,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(UniconsLine.home_alt), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(UniconsLine.user), label: 'Profile'),
      ],
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Main Page'),
      ),
    );
  }
}
