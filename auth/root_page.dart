import 'package:flutter/material.dart';
import 'package:univent/screens/loading_screen.dart';
import 'package:univent/screens/welcome_screen.dart';
import 'package:univent/auth/auth_status.dart';

import 'base_auth.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key, required this.auth});
  static const String id = 'root';

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user.uid;
        }

        authStatus = ((user?.uid == null || !user!.emailVerified))
            ? AuthStatus.notLoggedIn
            : AuthStatus.loggedIn;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user!.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.loggedIn;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.notLoggedIn;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return buildWaitingScreen();
      case AuthStatus.notLoggedIn:
        return const WelcomeScreen();
      case AuthStatus.loggedIn:
        if (_userId.isNotEmpty) {
          return const LoadingScreen();
        } else {
          return buildWaitingScreen();
        }
      default:
        return buildWaitingScreen();
    }
  }
}
