import 'package:flutter/material.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/screens/registration_screen.dart';
import 'package:univent/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String id = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('univent',
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
              const TextSpan(
                text: 'Welcome to ',
                children: <TextSpan>[
                  TextSpan(
                      text: 'univent',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
            RoundedButton(
              color: Theme.of(context).colorScheme.secondary,
              title: const Text('Log In'),
              action: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              color: Theme.of(context).colorScheme.secondary,
              title: const Text('Register'),
              action: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
