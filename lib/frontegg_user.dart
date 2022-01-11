import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/locatization.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FronteggUser {
  String? email;
  String? name;
  String? profilePictureUrl;
  bool? activatedForTenant;
  DateTime? createdAt;
  String? id;
  bool? isLocked;
  DateTime? lastLogin;
  dynamic metadata;
  bool? mfaEnrolled;
  // dynamic _permissions;
  String? phoneNumber;
  // String? _provider;
  // dynamic _roles;
  // String? _sub;
  String? tenantId;
  // dynamic _tenantIds;
  // dynamic _tenants;
  bool? verified;
  bool isAuthorized = false;
  late AuthApi _api;

  GitHubSignIn? _gitHubSignIn;

  FronteggUser({GitHubSignIn? git, Config? microsoft, Dio? dioForTests}) {
    _gitHubSignIn = git;
    if (microsoft != null) {
      _microsoftAuth = AadOAuth(microsoft);
    }
    dio = dioForTests ?? Dio();
    _api = AuthApi(dio);
  }

  Future<bool> loginPassword(String email, String password, BuildContext context) async {
    try {
      this.email = email;
      dynamic res = await _api.loginPassword(email, password, context);
      if (res == false) {
        return false;
      }
      setUserInfo(res);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      return await _api.forgotPassword(email);
    } catch (e) {
      throw tr('invalid_authentication');
    }
  }

  Future<void> setUserInfo(dynamic data) async {
    try {
      name = data['name'];
      profilePictureUrl = data['profilePictureUrl'];
      activatedForTenant = data['activatedForTenant'];
      createdAt = DateTime.parse(data['createdAt']);
      email = data['email'];
      id = data['id'];
      isLocked = data['isLocked'];
      lastLogin = DateTime.parse(data['lastLogin']);
      metadata = data['metadata'];
      mfaEnrolled = data['mfaEnrolled'];
      // _permissions = data['permissions'];
      phoneNumber = data['phoneNumber'];
      // _provider = data['provider'];
      // _roles = data['roles'];
      // _sub = data['sub'];
      tenantId = data['tenantId'];
      // _tenantIds = data['tenantIds'];
      // _tenants = data['tenants'];
      verified = data['verified'];
      isAuthorized = true;
    } catch (e) {
      throw 'Loading user error';
    }
  }

  Future<bool> loginCode(String email) async {
    try {
      this.email = email;
      return await _api.loginCode(email);
    } catch (e) {
      throw tr('invalid_authentication');
    }
  }

  Future<bool> checkCode(String code) async {
    try {
      setUserInfo(await _api.checkCode(code));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String name, String company) async {
    try {
      this.email = email;
      return await _api.signup(email, name, company);
    } catch (e) {
      throw tr('invalid_authentication');
    }
  }

  GoogleSignIn? _googleSignIn;

  Future<bool> loginOrSignUpGoogle() async {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
      GoogleSignInAccount? account = await _googleSignIn!.signIn();
      if (account != null) {
        GoogleSignInAuthentication auth = await account.authentication;
        return await socialLogin(auth, 'google');
      }

      throw tr('invalid_authentication');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> loginOrSignUpGithub(BuildContext context) async {
    try {
      if (_gitHubSignIn != null) {
        final GitHubSignInResult result = await _gitHubSignIn!.signIn(context);
        switch (result.status) {
          case GitHubSignInResultStatus.ok:
            final OAuthCredential auth = GithubAuthProvider.credential(result.token ?? '');
            return await socialLogin(auth, 'github');

          case GitHubSignInResultStatus.cancelled:
          case GitHubSignInResultStatus.failed:
            throw result.errorMessage;
        }
      } else {
        throw 'Set GitHubSignIn';
      }
    } catch (e) {
      rethrow;
    }
  }

  LoginResult? _facebookLoginResult;

  Future<bool> loginOrSignUpFacebook() async {
    try {
      _facebookLoginResult = await FacebookAuth.instance.login();
      final OAuthCredential auth = FacebookAuthProvider.credential(_facebookLoginResult!.accessToken!.token);
      if (_facebookLoginResult!.accessToken != null) {
        return await socialLogin(auth, 'facebook');
      }
      throw tr('invalid_authentication');
    } catch (e) {
      rethrow;
    }
  }

  AadOAuth? _microsoftAuth;

  Future<bool> loginOrSignUpMicrosoft() async {
    try {
      await _microsoftAuth!.login();
      String? accessToken = await _microsoftAuth!.getAccessToken();
      if (accessToken == null) {
        throw tr('invalid_authentication');
      }
      final bool succeed = await _api.socialLogin(accessToken, 'microsoft');
      if (!succeed) return false;
      setUserInfo(await _api.refresh());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> socialLogin(dynamic auth, String type) async {
    if (auth.accessToken == null) {
      throw tr('invalid_authentication');
    }
    final bool succeed = await _api.socialLogin(auth.accessToken!, type);
    if (!succeed) return false;
    setUserInfo(await _api.refresh());
    return true;
  }

  Future<void> logOut() async {
    if (_googleSignIn != null) {
      _googleSignIn!.signOut();
    }
    if (_facebookLoginResult != null) {
      await FacebookAuth.instance.logOut();
    }
    if (_microsoftAuth != null) {
      await _microsoftAuth!.logout();
    }
  }
}
