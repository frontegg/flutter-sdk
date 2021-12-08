import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/frontegg_user.dart';

class LoginWithPassword extends StatefulWidget {
  final FronteggUser user;
  const LoginWithPassword(this.user, {Key? key}) : super(key: key);

  @override
  _LoginWithPasswordState createState() => _LoginWithPasswordState();
}

class _LoginWithPasswordState extends State<LoginWithPassword> {
  bool sended = false;
  String? email;
  Widget paddings(Widget child, {bool onlyBottom = false}) {
    return Padding(padding: EdgeInsets.only(top: onlyBottom ? 0 : 30, bottom: 30), child: child);
  }

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return !sended
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              paddings(const Text(
                'Sign in',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              )),
              paddings(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        child: const Text('Sign up'),
                        onPressed: () {},
                      )
                    ],
                  ),
                  onlyBottom: true),
              paddings(
                  InputField('name@example.com', _controller, label: "Email", validateEmail: true, onChange: (_) {
                    setState(() {
                      error = null;
                    });
                  }),
                  onlyBottom: true),
              paddings(InputField('Enter Your Password', _controllerPassword, label: "Password", showIcon: true),
                  onlyBottom: true),
              if (error != null)
                paddings(
                    Text(
                      error ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    onlyBottom: true),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () async {
                  email = _controller.text;
                  try {
                    // sended = await widget.user.login(_controller.text);
                    error = null;
                  } catch (e) {
                    error = e.toString();
                  }
                  setState(() {});
                },
              )
            ],
          )
        : Container();
  }
}
