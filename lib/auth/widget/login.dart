import 'package:flutter/material.dart';
import 'package:frontegg/auth/auth.dart';
import 'package:frontegg/auth/widget/input_field.dart';

class Login extends StatefulWidget {
  final FronteggUser user;
  const Login(this.user, {Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool sended = false;
  String? email;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return !sended
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Email'),
              const SizedBox(height: 30),
              InputField('name@example.com', _controller),
              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () async {
                  email = _controller.text;
                  sended = await widget.user.login(_controller.text);
                  setState(() {});
                },
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Check your email"),
              Text('We have send an email to ${email ?? _controller.text}'),
              const SizedBox(height: 30),
              Container(
                color: Colors.yellow,
                child: Text('Input fields for code'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text('Resend code'),
                onPressed: () async {
                  sended = await widget.user.login(email ?? _controller.text);
                  setState(() {});
                },
              )
            ],
          );
  }
}
