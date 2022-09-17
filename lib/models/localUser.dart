import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Singleton class for the user using the app
class LocalUser {
  bool loggedIn = false;
  String userID = 'Guest';
  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';
  int school = 0;
  Map<dynamic, dynamic> allGames = {};


  // Database Variables
  final _auth = FirebaseAuth.instance;


  static final LocalUser _instance = LocalUser._internal();

  factory LocalUser() {
    return _instance;
  }

  login(String email, String password) async {
    try {
      final newUser = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print("USER ID HERE: " + newUser.toString());

      String? uid = newUser.user?.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid/personalInfo');
      DatabaseEvent user = await ref.once(DatabaseEventType.value);

      print("User Login Data Here:");
      print(user.snapshot.value);
      final map = user.snapshot.value as Map<dynamic, dynamic>;
      final firstName = map['firstName'] ?? 'Anonymous';
      final lastName = map['lastName'] ?? '';
      final school = map['school'] ?? 0;

      setInfo(uid!, firstName, lastName, email, school);

      print(firstName);


    }
    catch (e) {
      print(e);
    }
  }

  register(String email, String password, String firstName, String lastName) async {
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Setting up the user in Realtime database
      String? userID = newUser.user?.uid;
      DatabaseReference ref =
      FirebaseDatabase.instance.ref('users');

      await ref
          .child(userID!)
          .child('personalInfo')
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'emailAddress': email,
        'skill': 0,
        'userID': userID
      })
          .then((_) => setInfo(
          userID, firstName, lastName, email, 0))
          .catchError((error) => print('Error $error'));
    }
    catch (e) {
      print(e);
      rethrow;
    }
  }

  logout() async {
    await _auth.signOut();
    loggedIn = false;
    allGames.clear();
    userID = "Guest";
    firstName = "";
    lastName = "";
    email = "";
    school = 0;
  }

  setInfo(String id, String fName, String lName, String mail, int rating) {
    loggedIn = true;
    userID = id;
    firstName = fName;
    lastName = lName;
    email = mail;
    school = rating;
  }

  LocalUser.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        username = json['username'],
        email = json['email'],
        school = json['skill'];

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'firstName': firstName,
    'lastName': lastName,
    'username': username,
    'email': email,
    'skill': school
  };

  LocalUser._internal();
}
