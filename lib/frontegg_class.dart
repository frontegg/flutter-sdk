import 'package:flutter/material.dart';
import 'package:frontegg/auth/constants.dart';
import 'package:frontegg/auth/screens/login_common.dart';
import 'frontegg_user.dart';

class Frontegg {
  FronteggUser _user;

  Frontegg(baseUrl, headerImage) : _user = FronteggUser() {
    url = baseUrl;
    logo = headerImage;
  }

  void login(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(child: LoginCommon(_user)),
                ),
              )),
    );
  }

  FronteggUser signin(String email) {
    _user.email = email;
    return _user.signin();
  }

  bool logout() {
    return _user.logout();
  }

  FronteggUser get user => _user;
  bool get isAuthenticated => _user.email != null;
}
