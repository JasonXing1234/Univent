import 'package:flutter/material.dart';

class RadioCheck extends StatelessWidget {
  const RadioCheck(
      {super.key,
      required this.text,
      required this.groupValue,
      required this.action});

  final String text;
  final bool groupValue;
  final void Function(bool?) action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 32.0),
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            side: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 1.5),
            checkColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.secondary,
            shape: const CircleBorder(),
            value: groupValue,
            onChanged: action,
          ),
        ),
        Text(text),
      ],
    );
  }
}
