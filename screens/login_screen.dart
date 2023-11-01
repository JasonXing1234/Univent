import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:univent/components/buttons/plain_text_button.dart';
import 'package:univent/components/rounded_pasword_text_field.dart';
import 'package:univent/components/rounded_text_field.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/screens/home_screen.dart';
import 'package:univent/screens/reset_password_screen.dart';

import 'email_confirmation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;
  late String email;
  late String password;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool passwordVisible = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    super.initState();
  }

  void goToVerifyEmail() {
    Navigator.pushNamed(context, EmailConfirmationScreen.id);
  }

  void goToTodos() {
    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id, (r) => false,
        arguments: false);
  }

  Future<void> advanceLogin(bool isEmailVerified) async {
    if (!isEmailVerified) {
      goToVerifyEmail();
    } else {
      NotificationSettings settings =
          await _messaging.getNotificationSettings();
      // print('Current user permission: ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          await FirebaseMessaging.instance
              .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
        // print('User granted permission: ${settings.authorizationStatus}');
      }
      String? token = await _messaging.getToken();
      await _firestore
          .collection('tokens')
          .doc(token)
          .set({'user': _auth.currentUser!.uid});
      await _firestore
          .collection('user_tokens')
          .doc(_auth.currentUser?.uid)
          .collection('tokens')
          .doc(token)
          .set({});

      goToTodos();
    }
  }

  static customSnackBar(BuildContext context, String msg) {
    Color backgroundColor = Colors.red;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        msg,
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Text('univent',
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
        ),
      ),
      body: ProgressHUD(
        child: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 200.0,
                ),
                RoundedTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  callback: (value) {
                    email = value;
                  },
                  hint: 'Enter your email',
                ),
                RoundedPasswordTextField(
                  passwordVisible: passwordVisible,
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  callback: (value) {
                    password = value;
                  },
                  hint: 'Enter your password',
                  onToggle: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
                const SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  color: Theme.of(context).colorScheme.secondary,
                  title: const Text('Log In'),
                  action: () async {
                    final progress = ProgressHUD.of(context);
                    progress!.showWithText('Loading');
                    try {
                      await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      User? user = _auth.currentUser;
                      _emailController.clear();
                      _passwordController.clear();
                      await advanceLogin(user!.emailVerified);
                    } catch (e) {
                      customSnackBar(context, e.toString());
                    }
                    progress.dismiss();
                  },
                ),
                PlainTextButton(
                    action: () {
                      Navigator.pushNamed(context, ResetPasswordScreen.id);
                    },
                    title: 'Forgot your password? Click here!'),
              ],
            ),
          );
        }),
      ),
    );
  }
}
