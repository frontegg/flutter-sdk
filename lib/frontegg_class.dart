import 'package:flutter/material.dart';
import 'package:frontegg/auth/constants.dart';
import 'package:frontegg/auth/screens/login_common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontegg_user.dart';

class Frontegg {
  FronteggUser _user;

  Frontegg(baseUrl, headerImage) : _user = FronteggUser() {
    url = baseUrl;
    logo = headerImage;
  }

  Future<FronteggUser?> login(BuildContext context) async {
    final bool data = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(child: LoginCommon(_user)),
                ),
              )),
    );
    if (data) {
      return _user;
    } else {
      return null;
    }
  }

  FronteggUser signin(String email) {
    _user.email = email;
    return _user.signin();
  }

  Future<FronteggUser?> logout() async {
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
