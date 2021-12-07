import 'package:flutter/material.dart';
import 'package:frontegg/auth/constants.dart';
import 'package:frontegg/auth/widget/login.dart';
import 'auth/auth.dart';

class Frontegg {
  FronteggUser _user;

  Frontegg({@required baseUrl}) : _user = FronteggUser() {
    url = baseUrl;
  }

  Widget login() {
    return Login(_user);
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
