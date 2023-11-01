import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:univent/components/rounded_pasword_text_field.dart';
import 'package:univent/components/rounded_text_field.dart';
import 'package:univent/constants.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/screens/email_confirmation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  static const String id = 'registration_screen';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name;
  late String email;
  late String finalPassword;
  late String firstPassword = 'password';
  late String secondPassword = 'password';
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _customUniversityController;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  String? university;
  String customUniversity = '';
  bool allowCustomUni = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _customUniversityController = TextEditingController();

    super.initState();
  }

  void advanceRegistration() {
    Navigator.pushNamed(context, EmailConfirmationScreen.id);
  }

  static customSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        msg,
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static bool validateEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    var status = regExp.hasMatch(email);
    return status;
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> univeristyOptions = [
      DropdownMenuItem<String>(
          value: 'Brigham Young University',
          child: Text(
            'Brigham Young University',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          )),
      DropdownMenuItem<String>(
          value: 'Utah Valley University',
          child: Text('Utah Valley University',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary))),
      DropdownMenuItem<String>(
          value: 'University of Utah',
          child: Text('University of Utah',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary))),
      DropdownMenuItem<String>(
          value: 'Utah State University',
          child: Text('Utah State University',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary))),
      DropdownMenuItem<String>(
          value: 'Other',
          child: Text('Other',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)))
    ];
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
                  height: 100.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InputDecorator(
                    decoration: kTextFieldDecoration,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Select your University',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        items: univeristyOptions,
                        isExpanded: true,
                        value: university,
                        onChanged: (String? value) {
                          setState(() {
                            university = value!;
                            allowCustomUni = university == 'Other';
                          });
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
                allowCustomUni
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RoundedTextField(
                            controller: _customUniversityController,
                            callback: (value) {
                              customUniversity = value;
                            },
                            hint: 'Enter your University'),
                      )
                    : const SizedBox(height: 8.0),
                RoundedTextField(
                  hint: 'Enter your name',
                  callback: (value) {
                    name = value;
                  },
                  controller: _nameController,
                ),
                RoundedTextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  callback: (value) {
                    email = value.trim();
                  },
                  hint: 'Enter your email',
                ),
                RoundedPasswordTextField(
                  passwordVisible: passwordVisible,
                  controller: _passwordController,
                  callback: (value) {
                    firstPassword = value;
                  },
                  hint: 'Enter your password',
                  onToggle: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
                RoundedPasswordTextField(
                  passwordVisible: confirmPasswordVisible,
                  controller: _confirmPasswordController,
                  callback: (value) {
                    secondPassword = value;
                    if (firstPassword == secondPassword) {
                      finalPassword = secondPassword;
                    }
                  },
                  hint: 'Confirm your password',
                  onToggle: () {
                    setState(() {
                      confirmPasswordVisible = !confirmPasswordVisible;
                    });
                  },
                ),
                const SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  color: Theme.of(context).colorScheme.secondary,
                  title: const Text('Register'),
                  action: () async {
                    final progress = ProgressHUD.of(context);
                    try {
                      if (university == null) {
                        customSnackBar(
                            context, 'Please Select Your University');
                        return;
                      }
                      if (_nameController.text.isEmpty) {
                        customSnackBar(context, 'Please Enter Your Name');
                        return;
                      }
                      if (_emailController.text.isEmpty) {
                        customSnackBar(context, 'Please enter email');
                        return;
                      }
                      if (_passwordController.text.length < 8) {
                        customSnackBar(context,
                            'Password must be at least 8 characters long');
                        return;
                      }
                      var status = validateEmail(email);
                      if (!status) {
                        customSnackBar(context, 'Please enter a valid email');
                        return;
                      }
                      if (firstPassword == secondPassword) {
                        progress!.showWithText('Loading');
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: finalPassword);
                        User? user = _auth.currentUser;
                        if (university == 'Other') {
                          university = customUniversity;
                        }
                        if (user != null && !user.emailVerified) {
                          _firestore.collection('users').doc(user.uid).set({
                            'email': email,
                            'university': university,
                            'name': name,
                            'registered': false,
                            'has_seen_popup': false
                          });
                          _emailController.clear();
                          _nameController.clear();
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                          _customUniversityController.clear();
                          advanceRegistration();
                        }
                        progress.dismiss();
                      } else {
                        customSnackBar(context, 'Passwords must match');
                      }
                    } catch (e) {
                      progress!.dismiss();
                      customSnackBar(context, e.toString());
                    }
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
