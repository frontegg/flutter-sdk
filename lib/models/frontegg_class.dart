import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:frontegg_mobile/constants.dart';
import 'package:frontegg_mobile/auth/screens/login/login_common.dart';
import 'package:frontegg_mobile/auth/screens/signup.dart';
import 'package:frontegg_mobile/l10n/locatization.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontegg_user.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Frontegg {
  FronteggUser _user;
  dynamic git;
  dynamic microsoft;

  Frontegg(baseUrl, headerImage, {gitHubSignIn, localizationFileName, microsoftConfig, dio})
      : _user = FronteggUser(
            git: gitHubSignIn != null
                ? GitHubSignIn(
                    clientId: gitHubSignIn['clientId'],
                    clientSecret: gitHubSignIn['clientSecret'],
                    redirectUrl: 'https://frontegg.com/')
                : null,
            microsoft: microsoftConfig != null
                ? Config(
                    tenant: microsoftConfig['tenant'],
                    clientId: microsoftConfig['clientId'],
                    scope: "openid profile offline_access",
                    redirectUri: microsoftConfig['redirectUri'],
                    navigatorKey: navigatorKey)
                : null,
            dioForTests: dio) {
    url = baseUrl;
    // TODO: use a default logo here
    logo = headerImage = '';
    localTranslations = LocalTranslations(localizationFileName);
    git = gitHubSignIn;
    microsoft = microsoftConfig;
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
    _user = FronteggUser(
        git: git != null
            ? GitHubSignIn(
                clientId: git['clientId'], clientSecret: git['clientSecret'], redirectUrl: 'https://frontegg.com/')
            : null,
        microsoft: microsoft != null
            ? Config(
                tenant: microsoft['tenant'],
                clientId: microsoft['clientId'],
                scope: "openid profile offline_access",
                redirectUri: microsoft['redirectUri'],
                navigatorKey: navigatorKey)
            : null);
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
