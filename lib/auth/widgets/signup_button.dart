import 'package:flutter/material.dart';
import 'package:frontegg_mobile/auth/screens/login/login_common.dart';
import 'package:frontegg_mobile/auth/screens/signup.dart';
import 'package:frontegg_mobile/frontegg_user.dart';
import 'package:frontegg_mobile/locatization.dart';

class SignupButton extends StatelessWidget {
  final FronteggUser user;
  final bool signup;
  const SignupButton(this.user, this.signup, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(signup ? tr('dont_have_an_account') : tr('already_have_an_account')),
          const SizedBox(width: 5),
          TextButton(
            key: const Key('redirectButton'),
            child: Text(signup ? tr('signup') : tr('login')),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(child: signup ? Signup(user) : LoginCommon(user)),
                          ),
                        )),
              );
            },
          )
        ],
      ),
    );
  }
}
