// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini_demo/check_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, register }

class _AuthScreenState extends State<AuthScreen> {
  AuthMode authMode = AuthMode.login;

  @override
  void initState() {
    super.initState();
  }

  void googleLogin() {
    FirebaseAuth auth = FirebaseAuth.instance;
    final method = kIsWeb ? auth.signInWithPopup : auth.signInWithProvider;

    try {
      method(GoogleAuthProvider()).then(
        (value) {
          log("Google Login successful");
          checkUser();
        },
      ).catchError((e) {
        showError(e.toString());
      });
    } catch (e) {
      showError(e.toString());
    }
  }

  void guestLogin() {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      auth.signInAnonymously().then(
        (value) {
          log("Guest Login successful");
          checkUser();
        },
      ).catchError((e) {
        showError(e.toString());
      });
    } catch (e) {
      showError(e.toString());
    }
  }

  void checkUser() {
    checkUserAuth(context);
  }

  void logout() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text("Error"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    double widthPrcnt = MediaQuery.sizeOf(context).width <= 700 ? 0.8 : 0.35;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * widthPrcnt,
          child: Card.filled(
            elevation: 2,
            color: Theme.of(context).primaryColorLight,
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                )),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: 3.14 / 4,
                        child: Image.asset(
                            "assets/images/google-gemini-icon.png",
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox.square(dimension: 10),
                      Text("Gen-AI Demo",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  const SizedBox.square(dimension: 30),
                  SegmentedButton(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      selectedBackgroundColor:
                          Theme.of(context).primaryColorDark,
                      selectedForegroundColor:
                          Theme.of(context).primaryColorLight,
                      side: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1.5),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: AuthMode.login,
                        label: Text("Login"),
                      ),
                      ButtonSegment(
                        value: AuthMode.register,
                        label: Text("Register"),
                      ),
                    ],
                    selected: {authMode},
                    onSelectionChanged: (p0) => setState(() {
                      authMode = p0.first;
                    }),
                  ),
                  const SizedBox.square(dimension: 30),
                  authMode == AuthMode.login
                      ? const LoginForm()
                      : const RegisterForm(),
                  const SizedBox.square(dimension: 30),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    runSpacing: 10,
                    children: [
                      TextButton.icon(
                          onPressed: googleLogin,
                          label: const Text("Login with Google"),
                          style: TextButton.styleFrom(
                            side: const BorderSide(
                                width: 1, color: Colors.lightBlue),
                          ),
                          icon: Image.asset(
                            "assets/images/google_icon.png",
                            height: 20,
                            width: 20,
                            fit: BoxFit.contain,
                            color: Theme.of(context).primaryColor,
                          )),
                      TextButton.icon(
                          onPressed: guestLogin,
                          label: const Text("Login as Guest"),
                          style: TextButton.styleFrom(
                            side: const BorderSide(
                                width: 1, color: Colors.lightBlue),
                          ),
                          icon: const Icon(Icons.person)),
                    ],
                  ),
                  const SizedBox.square(dimension: 30),
                  TextButton.icon(
                      onPressed: logout,
                      label: const Text("Logout"),
                      style: TextButton.styleFrom(
                        side:
                            const BorderSide(width: 1, color: Colors.lightBlue),
                      ),
                      icon: const Icon(Icons.logout_rounded)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obsecureText = true;

  bool isLoading = false;

  void loginFun() {
    if (formKey.currentState!.validate()) {
      firebaseLogin();
    }
  }

  firebaseLogin() {
    setState(() {
      isLoading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      auth
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then(
        (value) {
          ScaffoldMessenger.maybeOf(context)!.showSnackBar(
              const SnackBar(content: Text("Login successfully")));
          setState(() {
            isLoading = false;
          });
          checkUser();
        },
      ).catchError((onError) {
        showError(onError.toString());
        setState(() {
          isLoading = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      showError(e.message.toString());
    } finally {
      emailController.clear();
      passwordController.clear();
    }
  }

  void checkUser() {
    checkUserAuth(context);
  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text("Error"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK")),
              ],
            ));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUnfocus,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            validator: (value) {
              final regex = RegExp(
                  r'^[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@([a-zA-Z0-9\-]{1,256}\.){1,5}[a-zA-Z]{2,256}$');
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!regex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox.square(dimension: 25),
          TextFormField(
            controller: passwordController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUnfocus,
            obscureText: obsecureText,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.password_rounded),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obsecureText = !obsecureText;
                      });
                    },
                    icon: obsecureText
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility_rounded))),
            validator: (value) {
              final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z]).{6,}$');
              if (value == null || value.trim().isEmpty) {
                return 'Please enter password';
              }
              if (!regex.hasMatch(value)) {
                return "Password must contain at least${"\n"}*One uppercase letter${"\n"}*One lowercase letter${"\n"}*6 or more characters";
              }
              return null;
            },
          ),
          const SizedBox.square(dimension: 25),
          FilledButton(
            onPressed: isLoading ? null : loginFun,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 18),
            ),
            child: isLoading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round, color: Colors.white),
                  )
                : const Text("Login"),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obsecureText = true;

  bool isLoading = false;

  void registerFun() {
    if (formKey.currentState!.validate()) {
      firebaseRegister();
    }
  }

  firebaseRegister() {
    setState(() {
      isLoading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      auth
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then(
        (value) {
          ScaffoldMessenger.maybeOf(context)!.showSnackBar(
              const SnackBar(content: Text("Account created successfully")));
          setState(() {
            isLoading = false;
          });
          checkUser();
        },
      ).catchError((onError) {
        showError(onError.toString());
        setState(() {
          isLoading = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      showError(e.message.toString());
    } finally {
      emailController.clear();
      passwordController.clear();
    }
  }

  void checkUser() {
    checkUserAuth(context);
  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text("Error"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUnfocus,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            validator: (value) {
              final regex = RegExp(
                  r'^[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@([a-zA-Z0-9\-]{1,256}\.){1,5}[a-zA-Z]{2,256}$');
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!regex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox.square(dimension: 25),
          TextFormField(
            controller: passwordController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUnfocus,
            obscureText: obsecureText,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.password_rounded),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obsecureText = !obsecureText;
                      });
                    },
                    icon: obsecureText
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility_rounded))),
            validator: (value) {
              final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z]).{4,}$');
              if (value == null || value.trim().isEmpty) {
                return 'Please enter password';
              }
              if (!regex.hasMatch(value)) {
                return "Password must contain at least${"\n"}*One uppercase letter${"\n"}*One lowercase letter${"\n"}*4 or more characters";
              }
              return null;
            },
          ),
          const SizedBox.square(dimension: 25),
          FilledButton(
            onPressed: isLoading ? null : registerFun,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 18),
            ),
            child: isLoading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round, color: Colors.white),
                  )
                : const Text("Register"),
          ),
        ],
      ),
    );
  }
}
