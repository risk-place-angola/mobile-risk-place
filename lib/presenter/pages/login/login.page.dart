import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:rpa/presenter/controllers/login.controller.dart';
import 'package:rpa/presenter/pages/register/register.page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginProvider = ref.read(loginControllerProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(children: [
        Center(
          child: Image.asset(
            "assets/rpa_logo.png",
            height: MediaQuery.of(context).size.height * 0.2,
          ),
        ),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.white.withOpacity(0.8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Login",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(
                              color: Theme.of(context).colorScheme.primary)),
                  _AuthTextField(
                      controller: loginProvider.emailController,
                      hintText: "Email"),
                  _AuthTextField(
                      controller: loginProvider.passwordController,
                      hintText: "Senha"),
                  loginProvider.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.9, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => loginProvider.login(context, ref),
                          child: Text("Entrar",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Theme.of(context).colorScheme.secondary,
                            thickness: 0.3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "ou",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context).colorScheme.secondary,
                            thickness: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AuthStateListener(
                      listener: (oldState, state, controller) {
                        if (state is AuthFailed) {
                          print("failed");
                          return;
                        }

                        if (state is SignedIn) {
                          print(controller.runtimeType);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //TODO:FIX - Credentiais are Exposed
                          OAuthProviderIconButton(
                            action: AuthAction.signUp,
                            providerConfig: GoogleProviderConfiguration(
                              clientId: Platform.isAndroid
                                  ? '1:853854219509:android:4526b68733431e6b8da9bc'
                                  : '1:853854219509:ios:10706b0c5d965e568da9bc',
                            ),
                          ),
                          OAuthProviderIconButton(
                            action: AuthAction.signIn,
                            providerConfig: FacebookProviderConfiguration(
                              clientId: Platform.isAndroid
                                  ? '1:853854219509:android:4526b68733431e6b8da9bc'
                                  : '1:853854219509:ios:10706b0c5d965e568da9bc',
                            ),
                          ),
                          const OAuthProviderIconButton(
                            action: AuthAction.signIn,
                            providerConfig: TwitterProviderConfiguration(
                                apiKey: '123',
                                apiSecretKey: '',
                                redirectUri: ''),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Não tem uma conta? ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Cadastre-se",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ]),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool? isPassword;
  const _AuthTextField(
      {Key? key, this.hintText, required this.controller, this.isPassword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword ?? false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
