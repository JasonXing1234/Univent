
import 'marketPlace.dart';
import 'routes.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key, required this.currentPage}) : super(key: key);
  final int currentPage;

  @override
  State<NavBar> createState() => _NavBarState(currentPage);
}

class _NavBarState extends State<NavBar> {
  final int _selectedIndex;

  _NavBarState(this._selectedIndex);

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, Routes.marketplace);
        break;
      case 1:
        Navigator.pushNamed(context, Routes.marketplace);
        break;
      case 2:
        Navigator.pushNamed(context, Routes.home);
        break;
      case 3:
        Navigator.pushNamed(context, Routes.home);
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.games),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_answer_outlined),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Settings',
        ),

      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF2B7FD9),
      unselectedItemColor: const Color(0xFF88CBF1),
      onTap: _onItemTapped,
    );
  }
}
