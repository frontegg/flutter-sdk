import 'package:flutter/material.dart';
import 'package:frontegg/locatization.dart';

class InputField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String? label;
  final Function(String)? onChange;
  final bool showIcon;
  final bool validateEmail;
  final bool validateNotEmpty;
  const InputField(this.hint, this.controller,
      {Key? key,
      this.label,
      this.onChange,
      this.showIcon = false,
      this.validateEmail = false,
      this.validateNotEmpty = true})
      : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool visible;

  String? validateEmail(String? value) {
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value != null && value.isEmpty) {
      return tr('required');
    } else {
      if (value != null && !regex.hasMatch(value)) {
        return tr('must_be_a_valid_email');
      } else {
        return null;
      }
    }
  }

  String? validateNotEmpty(String? value) {
    if (value != null && value.isEmpty) {
      return tr('required');
    } else {
      return null;
    }
  }

  @override
  void initState() {
    visible = !widget.showIcon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Form(
          autovalidateMode: widget.validateEmail ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: TextFormField(
            validator: widget.validateEmail
                ? validateEmail
                : widget.validateNotEmpty
                    ? validateNotEmpty
                    : null,
            controller: widget.controller,
            onChanged: widget.onChange,
            obscureText: !visible,
            decoration: InputDecoration(
                labelText: widget.label,
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF2F2F2))),
                hintText: widget.hint,
                suffixIcon: widget.showIcon
                    ? IconButton(
                        icon: const Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Icon(Icons.lock),
                        ),
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                      )
                    : null),
          ),
        ));
  }
}
