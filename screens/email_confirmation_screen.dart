import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:univent/screens/how_to_screen.dart';
import 'package:univent/components/buttons/rounded_button.dart';

class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({Key? key}) : super(key: key);

  static const String id = 'email_confirmation_screen';

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => checkEmail());
  }

  void advanceRegistration() {
    Navigator.pushNamedAndRemoveUntil(context, HowToScreen.id, (r) => false);
  }

  void checkEmail() async {
    checkEmailVerified();
    if (isEmailVerified) {
      timer?.cancel();
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'registered': true});
      _firestore
          .collection('ical_links')
          .doc(_auth.currentUser!.uid)
          .set({'links': {}});
      NotificationSettings settings = await _messaging.requestPermission(
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
      advanceRegistration();
    }
  }

  Future checkEmailVerified() async {
    await _auth.currentUser!.reload();
    setState(() {
      isEmailVerified = _auth.currentUser!.emailVerified;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void displaySnackBar(SnackBar snackBar) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

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
                RoundedButton(
                  // color: const Color.fromARGB(255, 45, 45, 45),
                  title: const Text('Send email verification'),
                  action: () async {
                    String snackBarText = 'Email verification has been sent.';
                    Color snackBarColor = Colors.green;
                    try {
                      await _auth.currentUser!.sendEmailVerification();
                    } catch (e) {
                      snackBarText = e.toString();
                      snackBarColor = Colors.red;
                    }
                    SnackBar snackBar = SnackBar(
                      backgroundColor: snackBarColor,
                      content: Text(
                        snackBarText,
                      ),
                    );
                    displaySnackBar(snackBar);
                  },
                ),
                Text(
                  'You may need to check your spam folder for an email from hq@univent.io',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
