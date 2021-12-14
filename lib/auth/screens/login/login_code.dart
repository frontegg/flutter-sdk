import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:frontegg/auth/widget/signup_button.dart';
import 'package:frontegg/frontegg_user.dart';
import 'package:frontegg/auth/widget/input_field.dart';

class LoginWithCode extends StatefulWidget {
  final FronteggUser user;
  const LoginWithCode(this.user, {Key? key}) : super(key: key);

  @override
  _LoginWithCodeState createState() => _LoginWithCodeState();
}

class _LoginWithCodeState extends State<LoginWithCode> {
  bool sended = false;
  String? email;
  bool loading = false;
  Widget paddings(Widget child, {bool onlyBottom = false}) {
    return Padding(padding: EdgeInsets.only(top: onlyBottom ? 0 : 30, bottom: 30), child: child);
  }

  List<InputCode> codeDigits = List.generate(6, (index) => InputCode(FocusNode(), TextEditingController()));
  final TextEditingController _controller = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    List<Widget> codeInputs = List.generate(6, (index) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          width: 50,
          height: 50,
          child: TextFormField(
            onTap: () {
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
    });

    return !sended
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              paddings(const Text(
                'Sign in',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              )),
              SignupButton(widget.user, true),
              paddings(
                  InputField('name@example.com', _controller, label: "Email", validateEmail: true, onChange: (_) {
                    setState(() {
                      error = null;
                    });
                  }),
                  onlyBottom: true),
              if (error != null)
                paddings(
                    Text(
                      error ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    onlyBottom: true),
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () async {
                  email = _controller.text;
                  try {
                    sended = await widget.user.loginCode(_controller.text);
                    error = null;
                  } catch (e) {
                    error = e.toString();
                  }
                  setState(() {});
                },
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              paddings(const Text(
                "Check your email",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              )),
              paddings(Text('We sent you a six digit code at ${email ?? _controller.text}'), onlyBottom: true),
              paddings(
                  const Text('Enter the generated 6-digit code below', style: TextStyle(fontWeight: FontWeight.bold)),
                  onlyBottom: true),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: codeInputs),
              const SizedBox(height: 30),
              ElevatedButton(
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Continue', style: TextStyle(fontSize: 18)),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                        });
                        try {
                          if (_controller.text.isEmpty) {
                            error = 'Email is required';
                            loading = false;
                          } else {
                            bool sended = await widget.user.checkCode(_controller.text);
                            if (sended) {
                              Navigator.pop(context, widget.user.isAuthorized);
                            }
                          }
                        } catch (e) {
                          error = e.toString();
                          loading = false;
                        }
                      },
              ),
              if (error != null) Text(error!),
              paddings(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Haven’t received it? "),
                      TextButton(
                        child: const Text('Resend a new code'),
                        onPressed: () async {
                          sended = await widget.user.loginCode(email ?? _controller.text);
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  onlyBottom: true),
            ],
          );
  }
}

class InputCode {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  InputCode(this.focusNode, this.controller);
}
