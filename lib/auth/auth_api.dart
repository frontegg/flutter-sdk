import 'package:dio/dio.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:frontegg/auth/screens/mfa/mfa.dart';
import 'package:frontegg/auth/social_class.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/locatization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  Dio dio = Dio();
  List<String>? cookies;

  Future<LoginType> checkType() async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.get('$url/frontegg/identity/resources/configurations/v1/public');

      String data = response.data['authStrategy'];
      switch (data) {
        case 'Code':
          return LoginType.code;
        case 'EmailAndPassword':
          return LoginType.password;
        case "MagicLink":
          return LoginType.link;
        default:
          throw data;
      }
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('something_went_wrong');
    }
  }

  Future<List<Social>> checkSocials() async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.get('$url/frontegg/identity/resources/sso/v2');
      final List<Social> res = response.data.map<Social>((e) => Social.fromJson(e)).toList();
      return res;
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('something_went_wrong');
    }
  }

  Future<dynamic> loginPassword(String email, String password, BuildContext context) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/user', data: {"email": email, "password": password});

      final data = response.data;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('emailForRecover', email);
      if (data['mfaRequired'] != null && data['mfaRequired']) {
        prefs.setString('mfaToken', data['mfaToken']);
        final verified = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TwoFactor(),
            ));
        if (verified == null) {
          return false;
        }
        if (verified == true) {
          return await getUserInfo();
        }
      } else {
        prefs.setString('accessToken', data['accessToken']);
        prefs.setString('expires', data['expires']);
        prefs.setInt('expiresIn', data['expiresIn']);
        prefs.setString('refreshToken', data['refreshToken']);

        return await getUserInfo();
      }
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';

      await dio.post('$url/frontegg/identity/resources/users/v1/passwords/reset', data: {"email": email});
      return true;
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> mfaCheck(String code, bool rememberDevice) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('mfaToken');
      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.post('$url/frontegg/identity/resources/auth/v1/user/mfa/verify',
          data: {"mfaToken": token, "value": code, "rememberDevice": rememberDevice});

      final data = response.data;
      prefs.setString('accessToken', data['accessToken']);
      prefs.setString('expires', data['expires']);
      prefs.setInt('expiresIn', data['expiresIn']);
      prefs.setString('refreshToken', data['refreshToken']);
      return true;
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> mfaRecover(String code) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('emailForRecover');
      await dio.post('$url/frontegg/identity/resources/auth/v1/user/mfa/recover',
          data: {"recoveryCode": code, 'email': email});

      return true;
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('invalid_authentication');
    }
  }

  Future<dynamic> getUserInfo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('accessToken') ?? '';
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["Authorization"] = "Bearer " + token;
      var response = await dio.get('$url/frontegg/identity/resources/users/v2/me');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data != null && e.response!.data.length > 0
            ? e.response!.data['errors'][0]
            : 'Loading user error';
      }
      throw 'Loading user error';
    }
  }

  Future<bool> loginCode(String email) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/passwordless/code/prelogin', data: {"email": email});
      cookies = response.headers.map['set-cookie'];

      return true;
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw tr('invalid_authentication');
    }
  }

  Future<dynamic> checkCode(String code) async {
    try {
      dio.options.headers["cookie"] = cookies?[0].split(';')[0];
      dio.options.headers['content-Type'] = 'application/json';

      var response = await dio.post(
        '$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin',
        data: {"token": code},
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', response.data['accessToken']);
      prefs.setString('expires', response.data['expires']);
      prefs.setInt('expiresIn', response.data['expiresIn']);
      prefs.setBool('mfaRequired', response.data['mfaRequired']);
      prefs.setString('refreshToken', response.data['refreshToken']);
      return await getUserInfo();
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0] ?? tr('something_went_wrong');
      }
      throw tr('something_went_wrong');
    }
  }

  Future<bool> signup(String email, String name, String company) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.post('$url/frontegg/identity/resources/users/v1/signUp',
          data: {"email": email, "name": name, "companyName": company});
      return response.statusCode == 201;
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          throw e.response!.data['errors'][0];
        }
      }
      throw tr('something_went_wrong');
    }
  }

  // Future<dynamic> refresh() async {
  //   try {
  //     dio.options.headers['content-Type'] = 'application/json';
  //     var response = await dio.post('$url/frontegg/identity/resources/auth/v1/user/token/refresh');

  //     final data = response.data;
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString('accessToken', data['accessToken']);
  //     prefs.setString('expires', data['expires']);
  //     prefs.setInt('expiresIn', data['expiresIn']);
  //     prefs.setBool('mfaRequired', data['mfaRequired']);
  //     prefs.setString('refreshToken', data['refreshToken']);
  //     return await getUserInfo();
  //   } catch (e) {
  //     print(e);
  //     if (e is DioError) {
  //       rethrow;
  //     }
  //     throw tr('invalid_authentication');
  //   }
  // }

  Future<bool> loginGoogle(GoogleSignInAuthentication user) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      // print('google 2 ${user.hashCode}\n!!! =>${user.accessToken}\n${user.idToken}');

      var response = await dio.post(
          '$url/frontegg/identity/resources/auth/v1/user/sso/google/postlogin?code=${user.hashCode}=${user.accessToken}',
          data: {});

      // final data = response.data;
      // print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      // print(e);
      if (e is DioError) {
        // print(e.response!.data);
        rethrow;
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> loginGitHub(OAuthCredential creds) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      // print('github 2 ${creds.idToken}\n===> ${creds.secret}\n===> ${creds.accessToken}');
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/user/sso/github/postlogin?code=&state=', data: {});

      // final data = response.data;
      // print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      // print(e);
      if (e is DioError) {
        // print(e.response!.data);
        rethrow;
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> loginFacebook(OAuthCredential creds) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      // print('facebook 2 ${creds.idToken}\n===> ${creds.secret}\n===> ${creds.accessToken}');
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/user/sso/facebook/postlogin?code=&state=', data: {});

      // final data = response.data;
      // print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      // print(e);
      if (e is DioError) {
        // print(e.response!.data);
        rethrow;
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> loginMicrosoft(String token) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio
          .post('$url/frontegg/identity/resources/auth/v1/user/sso/microsoft/postlogin?code=&state=', data: {});

      // final data = response.data;
      // print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioError) {
        rethrow;
      }
      throw tr('invalid_authentication');
    }
  }
}
