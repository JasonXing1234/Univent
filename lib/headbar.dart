import 'package:flutter/material.dart';

class HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  HeaderBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<HeaderBar> {
  bool warn = false;
  IconButton? action;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: backButton(context),
    );
  }

  backButton(BuildContext context) {
    if (!Navigator.canPop(context)) {
      return null;
    }
    return IconButton(
      tooltip: 'Leading Icon',
      icon: const Icon(
        Icons.keyboard_arrow_left,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
