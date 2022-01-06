import 'package:flutter/material.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';

class CodeInputContainer extends StatelessWidget {
  const CodeInputContainer(this.index, this.codeDigits, {this.clearError, Key? key}) : super(key: key);
  final int index;
  final List<InputCode> codeDigits;
  final Function? clearError;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        width: 50,
        height: 50,
        child: TextFormField(
          key: Key('input_code_$index'),
          onTap: () {
            if (clearError != null) {
              clearError!();
            }
            if (index > 0 && codeDigits[index].controller.text.isEmpty) {
              InputCode firstEmpty = codeDigits.firstWhere((element) => element.controller.text.isEmpty);
              FocusScope.of(context).requestFocus(firstEmpty.focusNode);
            }
            if (index > 0 && codeDigits[index].controller.text.isNotEmpty) {
              InputCode firstEmpty = codeDigits.lastWhere((element) => element.controller.text.isNotEmpty);
              FocusScope.of(context).requestFocus(firstEmpty.focusNode);
            }
          },
          keyboardType: TextInputType.number,
          onChanged: (String value) {
            if (value.length > 1) {
              if (index < 5) {
                codeDigits[index + 1].controller.text = value[value.length - 1];
              }
              codeDigits[index].controller.text = value.substring(0, value.length - 1);
            }
            if (value.isNotEmpty) {
              if (index < 5) {
                FocusScope.of(context).requestFocus(codeDigits[index + 1].focusNode);
              } else {
                FocusScope.of(context).unfocus();
              }
            }
            if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(codeDigits[index - 1].focusNode);
            }
          },
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          focusNode: codeDigits[index].focusNode,
          controller: codeDigits[index].controller,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFF2F2F2),
            border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF2F2F2))),
          ),
        ));
  }
}
