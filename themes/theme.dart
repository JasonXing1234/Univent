import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primaryColor: isDarkTheme ? Colors.black : Colors.white,
      colorScheme: ColorScheme(
        primary: isDarkTheme ? Colors.black : Colors.white,
        onPrimary: isDarkTheme ? Colors.black : Colors.white,
        secondary: isDarkTheme ? Colors.white : Colors.black,
        onSecondary: isDarkTheme ? Colors.white : Colors.black,
        error: Colors.white,
        onError: Colors.red,
        surface: isDarkTheme
            ? const Color.fromARGB(255, 33, 33, 33)
            : const Color.fromARGB(255, 233, 233, 233),
        onSurface: isDarkTheme ? Colors.black : Colors.white,
        background: isDarkTheme ? Colors.black : Colors.white,
        onBackground:
            isDarkTheme ? const Color.fromARGB(255, 33, 33, 33) : Colors.white,
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      scaffoldBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
      textTheme: TextTheme(
        titleLarge: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black, fontSize: 50),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(isDarkTheme
              ? const Color.fromARGB(255, 33, 33, 33)
              : Colors.black),
          foregroundColor: MaterialStateProperty.all<Color>(
            isDarkTheme ? Colors.white : Colors.white,
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          ),
          maximumSize: MaterialStateProperty.all<Size>(const Size(300.0, 45.0)),
          minimumSize: MaterialStateProperty.all<Size>(const Size(100.0, 45.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor:
            isDarkTheme ? const Color.fromARGB(255, 33, 33, 33) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isDarkTheme
                  ? const Color.fromARGB(255, 75, 75, 75)
                  : Colors.black,
              width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isDarkTheme
                  ? const Color.fromARGB(255, 175, 175, 175)
                  : Colors.black,
              width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        shape: Border(
            bottom: BorderSide(
                color: isDarkTheme ? Colors.white : Colors.black, width: 0.1)),
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        centerTitle: true,
        actionsIconTheme:
            IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
        iconTheme:
            IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black, fontSize: 30.0),
      ),
      drawerTheme: DrawerThemeData(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(32.0),
                bottomRight: Radius.circular(32.0))),
        backgroundColor: isDarkTheme
            ? const Color.fromARGB(255, 33, 33, 33)
            : const Color.fromARGB(255, 233, 233, 233),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDarkTheme
            ? const Color.fromARGB(255, 33, 33, 33)
            : const Color.fromARGB(255, 233, 233, 233),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDarkTheme ? const Color.fromARGB(255, 33, 33, 33) : Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        selectedItemColor: isDarkTheme ? Colors.white : Colors.black,
        elevation: 0.0,
      ),
    );
  }
}
