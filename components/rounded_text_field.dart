import 'package:flutter/material.dart';
import 'package:univent/constants.dart';

class RoundedTextField extends StatelessWidget {
  const RoundedTextField(
      {Key? key,
      required this.hint,
      required this.callback(value),
      this.controller,
      this.keyboardType,
      this.initVal,
      this.focus})
      : super(key: key);

  final String hint;
  final Function(dynamic)? callback;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? initVal;
  final FocusNode? focus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        focusNode: focus,
        initialValue: initVal,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        cursorColor: Theme.of(context).colorScheme.secondary,
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        onChanged: (value) => callback!(value),
        decoration: kTextFieldDecoration.copyWith(hintText: hint),
      ),
    );
  }
}
