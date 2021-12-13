import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';
import 'package:frontegg/auth/screens/login/login_password.dart';
import 'package:frontegg/auth/social_class.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/frontegg_user.dart';

import '../../constants.dart';

class LoginCommon extends StatefulWidget {
  final FronteggUser user;
  const LoginCommon(this.user, {Key? key}) : super(key: key);

  @override
  _LoginCommonState createState() => _LoginCommonState();
}

class _LoginCommonState extends State<LoginCommon> {
  LoginType? type;
  List<SocialType>? socials;
  String? error;
  String? socialError;

  final AuthApi _api = AuthApi();

  @override
  void initState() {
    checkType();
    checkSocials();
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

  checkSocials() async {
    try {
      socials = await _api.checkSocials();
      socialError = null;
    } catch (e) {
      error = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Logo(),
        type == null ? const CircularProgressIndicator() : getChild(),
        if (socials != null) getSocials()
      ],
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

  Widget getSocials() {
    if (socials == null) {
      return Container();
    }
    bool oneExist = false;
    for (SocialType item in socials!) {
      if (item.active ?? false) {
        oneExist = true;
        break;
      }
    }
    return oneExist
        ? Column(
            children: [
              const SizedBox(height: 10),
              const Text('------OR SIGN IN WITH------'),
              const SizedBox(height: 10),
              ...socials!.map((e) => e.active ?? false
                  ? ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      icon: SvgPicture.asset('asset/${e.type}.svg', semanticsLabel: 'Acme Logo'),
                      label: Text(
                        e.type != null ? '${e.type![0].toUpperCase()}${e.type!.substring(1)}' : '',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
                      ),
                      onPressed: () async {},
                    )
                  : Container())
            ],
          )
        : Container();
  }
}
