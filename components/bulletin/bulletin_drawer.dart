import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univent/admin/screens/review_flyer_screen.dart';
import 'package:univent/components/buttons/list_button.dart';
import 'package:univent/models/todo_data.dart';
import 'package:univent/screens/colors_screen.dart';
import 'package:univent/screens/how_to_screen.dart';
import 'package:univent/screens/logout_screen.dart';
import 'package:univent/screens/my_flyers_screen.dart';

class BulletinDrawer extends StatelessWidget {
  const BulletinDrawer(
      {required this.scaffoldKey,
      required this.isAdmin,
      required this.hasFlyers,
      super.key});

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isAdmin;
  final bool hasFlyers;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome, ${Provider.of<TodoData>(context).userName}!',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            hasFlyers
                ? ListButton(
                    icon: Icons.dashboard,
                    action: () {
                      Navigator.pushNamed(context, MyFlyersScreen.id);
                    },
                    title: 'My Flyers',
                  )
                : const SizedBox(width: 0.0),
            isAdmin
                ? ListButton(
                    icon: Icons.admin_panel_settings_outlined,
                    action: () {
                      Navigator.pushNamed(context, ReviewFlyerScreen.id);
                    },
                    title: 'Review Flyers',
                  )
                : const SizedBox(width: 0.0),
            ListButton(
              icon: Icons.color_lens,
              action: () {
                Navigator.pushNamed(context, ColorsScreen.id);
              },
              title: 'Colors',
            ),
            ListButton(
              icon: Icons.logout,
              action: () {
                Navigator.pushNamed(context, LogoutScreen.id);
              },
              title: 'Log Out',
            ),
            ListButton(
              icon: Icons.question_mark,
              action: () {
                Navigator.pushNamed(context, HowToScreen.id);
              },
              title: 'Help',
            ),
          ],
        ),
      ),
    );
  }
}
