import 'dart:async';
import 'dart:developer';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/utils/navigator_handler.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/models/warns.model.dart';
import 'package:rpa/presenter/controllers/alert.controller.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/controllers/home.controller.dart';
import 'package:rpa/presenter/controllers/warns.controller.dart';
import 'package:rpa/presenter/pages/alert_page.dart';
import 'package:rpa/presenter/pages/home_page/widgets/alerts_list.widget.dart';
import 'package:rpa/presenter/pages/profile/profile.view.dart';
import 'package:unicons/unicons.dart';
import 'package:latlong2/latlong.dart' as ll;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  RecorderController _controller = RecorderController();
  Timer? _timer;
  late User? _user;
  List<Warning> _warnings = [];
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
  void initState() {
    ref.read(authControllerProvider).initialize();
    _user = ref.read(authControllerProvider.notifier).userStored;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavigation(
          pageIndex: ref.watch(homeProvider).pageIndex,
          updateIndex: ref.read(homeProvider).updateIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _user!.isRFCE ?? false
          ? null
          : GestureDetector(
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
          MainPage(warnings: _warnings),
          const ProfileView(),
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
  MainPage({Key? key, this.warnings}) : super(key: key);
  List<Warning>? warnings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alertas',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
      body: AlertsList(warns: warnings!.reversed.toList()),
    );
  }
}
