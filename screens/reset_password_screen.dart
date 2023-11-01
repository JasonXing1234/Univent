import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:univent/components/rounded_text_field.dart';
import 'package:univent/screens/how_to_screen.dart';
import 'package:univent/components/buttons/rounded_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  static const String id = 'reset_password_screen';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late TextEditingController _emailController;

  bool isEmailVerified = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  void advanceRegistration() {
    Navigator.pushNamedAndRemoveUntil(context, HowToScreen.id, (r) => false);
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
                RoundedTextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    callback: (value) {
                      email = value.trim();
                    },
                    hint: 'Enter your email'),
                const SizedBox(
                  height: 16.0,
                ),
                RoundedButton(
                  color: Theme.of(context).colorScheme.secondary,
                  title: const Text('Reset Password'),
                  action: () async {
                    String snackBarText = 'Password reset email has been sent.';
                    Color snackBarColor = Colors.green;
                    await _auth
                        .sendPasswordResetEmail(email: email)
                        .catchError((e) {
                      snackBarText = e.toString();
                      snackBarColor = Colors.red;
                    });
                    _emailController.clear();
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
