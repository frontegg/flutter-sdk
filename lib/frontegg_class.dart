import 'package:flutter/material.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/auth/screens/login/login_common.dart';
import 'package:frontegg/auth/signup.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontegg_user.dart';

class Frontegg {
  FronteggUser _user;

  Frontegg(baseUrl, headerImage, {gitHubSignIn})
      : _user = FronteggUser(
            git: GitHubSignIn(
                clientId: gitHubSignIn['clientId'],
                clientSecret: gitHubSignIn['clientSecret'],
                redirectUrl: 'https://frontegg.com/')) {
    url = baseUrl;
    logo = headerImage;
  }

  Future<FronteggUser?> login(BuildContext context) async {
    final bool? data = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(child: LoginCommon(_user)),
                ),
              )),
    );
    if (data == true) {
      return _user;
    } else {
      return null;
    }
  }

  Future<FronteggUser?> signup(BuildContext context) async {
    final bool? data = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(child: Signup(_user)),
                ),
              )),
    );
    if (data == true) {
      return _user;
    } else {
      return null;
    }
  }

  Future<FronteggUser?> logout() async {
    await _user.logOut();
    _user = FronteggUser();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('expires');
    await prefs.remove('expiresIn');
    await prefs.remove('mfaRequired');
    await prefs.remove('refreshToken');
    return _user;
  }

  FronteggUser get user => _user;
  bool get isAuthenticated => _user.email != null;
}
