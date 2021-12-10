import 'package:flutter/material.dart';
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
      body: Center(child: Text('signup')),
    );
  }
}
