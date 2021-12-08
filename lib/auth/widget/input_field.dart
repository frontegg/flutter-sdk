import 'package:flutter/material.dart';
import 'package:frontegg/auth/constants.dart';

class InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? label;
  final Function(String)? onChange;
  const InputField(this.hint, this.controller, {Key? key, this.label, this.onChange}) : super(key: key);

  String? validateEmail(String? value) {
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value != null && !regex.hasMatch(value)) {
      return 'Must be a valid email';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            validator: validateEmail,
            controller: controller,
            onChanged: onChange,
            decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF2F2F2))),
                hintText: hint),
          ),
        ));
  }
}
