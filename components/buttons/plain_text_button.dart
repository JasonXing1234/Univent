import 'package:flutter/material.dart';

class PlainTextButton extends StatelessWidget {
  const PlainTextButton(
      {Key? key, required this.title, required this.action, this.color})
      : super(key: key);

  final String title;
  final Function()? action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: action,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary)),
      child: Text(
        title,
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
    );
  }
}
