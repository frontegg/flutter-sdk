import 'package:flutter/material.dart';
import 'package:frontegg/auth/screens/login/login_common.dart';
import 'package:frontegg/auth/signup.dart';
import 'package:frontegg/frontegg_user.dart';

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
          Text(signup ? "Don't have an account? " : "Already have an account? "),
          TextButton(
            child: Text(signup ? 'Sign up' : 'Log in'),
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
