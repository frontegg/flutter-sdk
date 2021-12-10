import 'package:flutter/material.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/auth/widget/signup_button.dart';
import 'package:frontegg/frontegg_user.dart';

class Signup extends StatefulWidget {
  final FronteggUser user;
  const Signup(this.user, {Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Logo(),
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                'Sign Up',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            SignupButton(widget.user, false),
          ],
        ),
      ),
    );
  }
}
