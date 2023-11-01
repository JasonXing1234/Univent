import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {Key? key, required this.title, required this.action, this.color})
      : super(key: key);

  final Text title;
  final Function()? action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextButton(
        onPressed: action,
        style: color != null
            ? ButtonStyle(
                backgroundColor: color != null
                    ? MaterialStateProperty.all<Color>(color as Color)
                    : null,
                foregroundColor: MaterialStateProperty.all<Color>(
                    color == Colors.black ? Colors.white : Colors.black))
            : const ButtonStyle(),
        child: title,
      ),
    );
  }
}
