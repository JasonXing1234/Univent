import 'package:flutter/material.dart';

class ListButton extends StatelessWidget {
  const ListButton(
      {Key? key, required this.title, required this.action, required this.icon})
      : super(key: key);

  final String title;
  final Function()? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 0.05,
        ),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Material(
          color: Colors.transparent,
          child: MaterialButton(
            onPressed: action,
            minWidth: 100.0,
            height: 42.0,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 16.0),
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
