import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const InputField(this.hint, this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(controller: controller, decoration: InputDecoration.collapsed(hintText: hint));
  }
}
