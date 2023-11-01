import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/admin/screens/review_flyer_screen.dart';
import 'package:univent/auth/base_auth.dart';
import 'package:univent/auth/root_page.dart';
import 'package:univent/models/flyer_data.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/screens/add_flyer_screen.dart';
import 'package:univent/screens/bulletin_screen.dart';
import 'package:univent/screens/add_ical_link_screen.dart';
import 'package:univent/screens/colors_screen.dart';
import 'package:univent/screens/email_confirmation_screen.dart';
import 'package:univent/screens/home_screen.dart';
import 'package:univent/screens/how_to_screen.dart';
import 'package:univent/screens/loading_screen.dart';
import 'package:univent/screens/login_screen.dart';
import 'package:univent/screens/logout_screen.dart';
import 'package:univent/screens/my_flyers_screen.dart';
import 'package:univent/screens/registration_screen.dart';
import 'package:univent/screens/remove_ical_link_screen.dart';
import 'package:univent/screens/reset_password_screen.dart';
import 'package:univent/screens/todo_screen.dart';
import 'package:univent/screens/welcome_screen.dart';
import 'package:univent/firebase_options.dart';
import 'package:univent/themes/theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. debug provider
    // 2. safety net provider
    // 3. play integrity provider
    androidProvider: AndroidProvider.debug,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // if (kReleaseMode) {
  //   CustomImageCache();
  // }
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TodoData todoData = TodoData();
  FlyerData flyerData = FlyerData();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    todoData.setDarkTheme(await todoData.darkThemePreference.getTheme());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return todoData;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return flyerData;
          },
        )
      ],
      child: Consumer<TodoData>(
        builder: (context, value, child) {
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild!.unfocus();
              }
            },
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: RootPage(auth: Auth()),
              initialRoute: RootPage.id,
              onGenerateRoute: (settings) {
                if (settings.name == HomeScreen.id) {
                  final args = settings.arguments as bool;
                  return MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen(
                        fromRestart: args,
                      );
                    },
                  );
                }
                if (settings.name == TodoScreen.id) {
                  final args = settings.arguments as bool;
                  return MaterialPageRoute(
                    builder: (context) {
                      return TodoScreen(
                        fromRestart: args,
                      );
                    },
                  );
                }
                return null;
              },
              routes: {
                WelcomeScreen.id: (context) => const WelcomeScreen(),
                LoginScreen.id: (context) => const LoginScreen(),
                LogoutScreen.id: (context) => const LogoutScreen(),
                RegistrationScreen.id: (context) => const RegistrationScreen(),
                HowToScreen.id: (context) => const HowToScreen(),
                ResetPasswordScreen.id: (context) =>
                    const ResetPasswordScreen(),
                EmailConfirmationScreen.id: (context) =>
                    const EmailConfirmationScreen(),
                AddIcalLinkScreen.id: (context) => const AddIcalLinkScreen(),
                RemoveIcalLinkScreen.id: (context) =>
                    const RemoveIcalLinkScreen(),
                LoadingScreen.id: (context) => const LoadingScreen(),
                BulletinScreen.id: (context) => const BulletinScreen(),
                AddFlyerScreen.id: (context) => const AddFlyerScreen(),
                ReviewFlyerScreen.id: (context) => const ReviewFlyerScreen(),
                MyFlyersScreen.id: (context) => const MyFlyersScreen(),
                ColorsScreen.id: (context) => const ColorsScreen()
              },
              theme: Styles.themeData(todoData.darkTheme, context),
            ),
          );
        },
      ),
    );
  }
}
