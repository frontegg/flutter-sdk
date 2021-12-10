import 'package:flutter/material.dart';
import 'package:frontegg/auth/signup.dart';
import 'package:frontegg/frontegg_user.dart';

class SignupButton extends StatelessWidget {
  final FronteggUser user;
  const SignupButton(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account? "),
          TextButton(
            child: const Text('Sign up'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(child: Signup(user)),
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
