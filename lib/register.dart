import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'components/RoundedButton.dart';
import 'home.dart';
import 'verify.dart';
import '../../models/localUser.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String email;
  late String password;
  late String firstName;
  late String lastName;
  LocalUser localUser = LocalUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
              ),
              TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  password = value;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  firstName = value;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your first name',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  lastName = value;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your last name',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Register',
                color: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    await localUser.register(email, password, firstName, lastName).then((_){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Verify()));
                    });
                  }
                  catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                  setState(() {
                    showSpinner = false;
                  });
                  if (localUser.loggedIn) {
                    Navigator.pushNamed(context, HomePage.routeName);
                  }
                },
              ),
              RoundedButton(
                title: 'Go to Login',
                color: Colors.lightBlueAccent,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ));
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
