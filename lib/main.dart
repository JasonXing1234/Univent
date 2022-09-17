import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled6/register.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'home.dart';
import 'routes.dart';

// TODO: Change theme color according to school
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const appTitle = 'Univent';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE0C61B),
        textTheme: const TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white10,
        ),
      ),
      home: const LoginPage(),
      routes: {
        Routes.home: (context) => const HomePage(),
        Routes.login: (context) => const LoginPage(),
        Routes.register: (context) => const RegisterPage(),

      },
    );
  }
}
