import 'package:flutter/material.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';
import 'package:frontegg/auth/screens/login/login_password.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/auth/widget/social_buttons.dart';
import 'package:frontegg/frontegg_user.dart';

import '../../../constants.dart';

class LoginCommon extends StatefulWidget {
  final FronteggUser user;
  const LoginCommon(this.user, {Key? key}) : super(key: key);

  @override
  _LoginCommonState createState() => _LoginCommonState();
}

class _LoginCommonState extends State<LoginCommon> {
  LoginType? type;
  String? error;

  final AuthApi _api = AuthApi();

  @override
  void initState() {
    checkType();
    super.initState();
  }

  checkType() async {
    try {
      type = await _api.checkType();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          const Logo(),
          type == null ? const CircularProgressIndicator() : getChild(),
          SocialButtons(AuthType.login, widget.user),
          const SizedBox(height: 50)
        ],
      ),
    );
  }

  Widget getChild() {
    switch (type) {
      case LoginType.code:
        return LoginWithCode(widget.user);
      case LoginType.password:
        return LoginWithPassword(widget.user);
      case LoginType.link:
        return const Center(
            child: Text('Authentification with Magic Link is not available on mobile devices',
                style: TextStyle(color: Colors.red)));
      default:
        return Text(error ?? 'Something went wrong');
    }
  }
}
