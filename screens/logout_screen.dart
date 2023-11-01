import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/screens/welcome_screen.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  static const String id = 'logout_screen';

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;
  late String email;
  late String password;

  void returnToWelcomeScreen() {
    Navigator.pushNamedAndRemoveUntil(context, WelcomeScreen.id, (r) => false);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                  const TextSpan(
                    text: 'Thanks for using ',
                    children: <TextSpan>[
                      TextSpan(
                          text: 'univent',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RoundedButton(
                    color: Theme.of(context).colorScheme.secondary,
                    title: const Text('Logout'),
                    action: () async {
                      final progress = ProgressHUD.of(context);
                      progress!.showWithText('Loading');
                      String? token = await _messaging.getToken();
                      await _firestore.collection('tokens').doc(token).delete();
                      await _firestore
                          .collection('user_tokens')
                          .doc(_auth.currentUser?.uid)
                          .collection('tokens')
                          .doc(token)
                          .delete();
                      _messaging.deleteToken();
                      _auth.signOut();
                      returnToWelcomeScreen();
                      // TODO: DELETE DATA FROM PROVIDER
                      progress.dismiss();
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
