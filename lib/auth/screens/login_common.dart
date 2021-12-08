import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontegg/auth/screens/login_code.dart';
import 'package:frontegg/auth/screens/login_password.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/frontegg_user.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class LoginCommon extends StatefulWidget {
  final FronteggUser user;
  const LoginCommon(this.user, {Key? key}) : super(key: key);

  @override
  _LoginCommonState createState() => _LoginCommonState();
}

class _LoginCommonState extends State<LoginCommon> {
  LoginType? type;
  String? error;
  @override
  void initState() {
    checkType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [const Logo(), type == null ? const CircularProgressIndicator() : getChild()],
    );
  }

  Widget getChild() {
    switch (type) {
      case LoginType.code:
        return LoginWithCode(widget.user);
      case LoginType.password:
        return LoginWithPassword(widget.user);
      default:
        return Text(error ?? 'Something went wrong');
    }
  }

  Future<void> checkType() async {
    try {
      var response = await http.get(Uri.parse('$url/frontegg/identity/resources/configurations/v1/public'),
          headers: {'Content-type': 'application/json'});
      if (response.statusCode == 200) {
        String data = jsonDecode(response.body)['authStrategy'];
        setState(() {
          switch (data) {
            case 'Code':
              type = LoginType.code;
              error = null;
              break;
            case 'EmailAndPassword':
              type = LoginType.password;
              break;
            default:
              error = data;
          }
        });
      } else {
        throw response.statusCode;
      }
    } catch (e) {
      setState(() {
        error = 'Something went wrong';
      });
    }
  }
}
