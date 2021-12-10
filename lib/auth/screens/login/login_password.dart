import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:frontegg/auth/screens/forgot_password.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/signup_button.dart';
import 'package:frontegg/frontegg_user.dart';

class LoginWithPassword extends StatefulWidget {
  final FronteggUser user;
  const LoginWithPassword(this.user, {Key? key}) : super(key: key);

  @override
  _LoginWithPasswordState createState() => _LoginWithPasswordState();
}

class _LoginWithPasswordState extends State<LoginWithPassword> {
  bool loading = false;
  Widget paddings(Widget child, {bool onlyBottom = false}) {
    return Padding(padding: EdgeInsets.only(top: onlyBottom ? 0 : 30, bottom: 30), child: child);
  }

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        paddings(const Text(
          'Sign in',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        )),
        SignupButton(widget.user),
        paddings(
            InputField('name@example.com', _controller, label: "Email", validateEmail: true, onChange: (_) {
              setState(() {
                error = null;
              });
            }),
            onlyBottom: true),
        paddings(InputField('Enter Your Password', _controllerPassword, label: "Password", showIcon: true),
            onlyBottom: true),
        TextButton(
          child: const Text('Forgot Password?'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPassword(widget.user)),
            );
          },
        ),
        if (error != null)
          paddings(
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
              onlyBottom: true),
        ElevatedButton(
          child: loading ? const CircularProgressIndicator() : const Text('Login'),
          onPressed: loading
              ? null
              : () async {
                  setState(() {
                    loading = true;
                  });
                  try {
                    if (_controller.text.isEmpty || _controllerPassword.text.isEmpty) {
                      error = 'Email and password are required';
                      loading = false;
                    } else {
                      bool sended = await widget.user.loginPassword(_controller.text, _controllerPassword.text);
                      if (sended) {
                        Navigator.pop(context, widget.user.isAuthorized);
                      }
                    }
                  } catch (e) {
                    error = e.toString();
                    loading = false;
                  }
                  setState(() {});
                },
        )
      ],
    );
  }
}
