import 'package:flutter/material.dart';
import 'package:univent/constants.dart';

class RoundedPasswordTextField extends StatelessWidget {
  const RoundedPasswordTextField(
      {Key? key,
      required this.hint,
      required this.callback(value),
      required this.onToggle(),
      required this.passwordVisible,
      this.controller,
      this.keyboardType,
      this.initVal})
      : super(key: key);

  final String hint;
  final Function(dynamic)? callback;
  final Function()? onToggle;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? initVal;
  final bool passwordVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
          initialValue: initVal,
          obscureText: !passwordVisible,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          cursorColor: Theme.of(context).colorScheme.secondary,
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          onChanged: (value) => callback!(value),
          decoration: kTextFieldDecoration.copyWith(
              contentPadding: const EdgeInsets.fromLTRB(50.0, 1.0, 0.0, 1.0),
              hintText: hint,
              suffixIcon: IconButton(
                color: Colors.grey,
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggle,
              ))),
    );
  }
}
