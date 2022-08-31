import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontegg_mobile/auth/screens/mfa/mfa.dart';
import 'package:frontegg_mobile/models/social_class.dart';
import 'package:frontegg_mobile/constants.dart';
import 'package:frontegg_mobile/l10n/locatization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;
  List<String>? cookies;

  Future<LoginType> checkType() async {
    try {
      _dio.options.headers['content-Type'] = 'application/json';
      var response = await _dio.get('$url/frontegg/identity/resources/configurations/v1/public');

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
      _dio.options.headers['content-Type'] = 'application/json';
      var response = await _dio.get('$url/frontegg/identity/resources/sso/v2');
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
      _dio.options.headers['content-Type'] = 'application/json';
      var response = await _dio
          .post('$url/frontegg/identity/resources/auth/v1/user', data: {"email": email, "password": password});

      final data = response.data;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('emailForRecover', email);

      if (data['mfaRequired'] != null && data['mfaRequired']) {
        prefs.setString('mfaToken', data['mfaToken']);
        final verified = await Navigator.push(context, MaterialPageRoute(builder: (context) => const TwoFactor()));
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
      _dio.options.headers['content-Type'] = 'application/json';

      await _dio.post('$url/frontegg/identity/resources/users/v1/passwords/reset', data: {"email": email});
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
      _dio.options.headers['content-Type'] = 'application/json';

      var response = await _dio.post('$url/frontegg/identity/resources/auth/v1/user/mfa/verify',
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
      _dio.options.headers['content-Type'] = 'application/json';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('emailForRecover');
      await _dio.post('$url/frontegg/identity/resources/auth/v1/user/mfa/recover',
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
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers["Authorization"] = "Bearer $token";
      var response = await _dio.get('$url/frontegg/identity/resources/users/v2/me');
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
      _dio.options.headers['content-Type'] = 'application/json';
      var response = await _dio
          .post('$url/frontegg/identity/resources/auth/v1/passwordless/code/prelogin', data: {"email": email});
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
      _dio.options.headers["cookie"] = cookies?[0].split(';')[0];
      _dio.options.headers['content-Type'] = 'application/json';

      var response = await _dio.post(
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

  Future<bool> signup(String email, String name, String companyName) async {
    try {
      _dio.options.headers['content-Type'] = 'application/json';
      var response = await _dio.post('$url/frontegg/identity/resources/users/v1/signUp',
          // TODO: do we want tenant sign up here? if so, companyName should be removed
          data: {"email": email, "name": name, "companyName": companyName});
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

  Future<dynamic> refresh() async {
    try {
      _dio.options.headers["cookie"] = cookies?[0].split(';')[0];
      _dio.options.headers['content-Type'] = 'application/json';
      var response = await _dio.post('$url/frontegg/identity/resources/auth/v1/user/token/refresh');

      final data = response.data;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', data['accessToken']);
      prefs.setString('expires', data['expires']);
      prefs.setInt('expiresIn', data['expiresIn']);
      prefs.setBool('mfaRequired', data['mfaRequired']);
      prefs.setString('refreshToken', data['refreshToken']);
      return await getUserInfo();
    } catch (e) {
      if (e is DioError) {
        rethrow;
      }
      throw tr('invalid_authentication');
    }
  }

  Future<bool> socialLogin(String token, String type) async {
    try {
      _dio.options.headers['content-Type'] = 'application/json';
      var response =
          await _dio.post('$url/frontegg/identity/resources/auth/v1/user/sso/$type/postlogin?access_token=$token');
      cookies = response.headers.map['set-cookie'];
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioError) {
        rethrow;
      }
      throw tr('invalid_authentication');
    }
  }
}
