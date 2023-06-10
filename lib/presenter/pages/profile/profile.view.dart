import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/controllers/home.controller.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  User? _userStored;

  _getStoredUser() async {
    ref.read(authControllerProvider).setUser();
    setState(() {});
  }

  @override
  void initState() {
    _getStoredUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userStored = ref.watch(authControllerProvider).userStored;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Text('User'),
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              text: 'Nome: ',
              style: const TextStyle(color: Colors.black, fontSize: 20),
              children: [
                TextSpan(
                  text: _userStored?.name ?? '',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              text: 'Email: ',
              style: const TextStyle(color: Colors.black, fontSize: 20),
              children: [
                TextSpan(
                  text: _userStored?.email ?? '',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              text: 'Telefone: ',
              style: const TextStyle(color: Colors.black, fontSize: 20),
              children: [
                TextSpan(
                  text: _userStored?.phoneNumber ?? '',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
                ref.read(homeProvider.notifier).pageIndex = 0;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
              child: const Text('Logout')),
        ],
      ),
    );
  }
}
