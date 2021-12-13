import 'package:dio/dio.dart';
import 'package:frontegg/auth/constants.dart';
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
        default:
          throw data;
      }
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw 'Something went wrong';
    }
  }

  Future<dynamic> loginPassword(String email, String password) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/user', data: {"email": email, "password": password});

      final data = response.data;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', data['accessToken']);
      prefs.setString('expires', data['expires']);
      prefs.setInt('expiresIn', data['expiresIn']);
      prefs.setBool('mfaRequired', data['mfaRequired']);
      prefs.setString('refreshToken', data['refreshToken']);
      return await getUserInfo();
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw 'Invalid authentication@@@@@@';
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response =
          await dio.post('$url/frontegg/identity/resources/users/v1/passwords/reset', data: {"email": email});
      return true;
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw 'Invalid authentication';
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
        throw e.response!.data['errors'][0];
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
      throw 'Invalid authentication';
    }
  }

  Future<dynamic> checkCode(String code) async {
    try {
      print(cookies);
      dio.options.headers["cookie"] = cookies?[0].split(';')[0];
      dio.options.headers['content-Type'] = 'application/json';
      print(dio.options.headers);
      print('$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin');

      var response = await dio.post(
        '$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin',
        data: {"token": code},
      );
      print('${response.statusCode} ${response.data} ${response.headers}');
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('accessToken', response.data['accessToken']);
        prefs.setString('expires', response.data['expires']);
        prefs.setInt('expiresIn', response.data['expiresIn']);
        prefs.setBool('mfaRequired', response.data['mfaRequired']);
        prefs.setString('refreshToken', response.data['refreshToken']);
        return await getUserInfo();
      }

      throw response.data['errors'][0];
    } catch (e) {
      if (e is DioError && e.response != null) {
        throw e.response!.data['errors'][0];
      }
      throw 'Something went wrong';
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
          print('${e.response!.statusCode} ${e} ${e.response!.data['errors'][0]}');
          throw e.response!.data['errors'][0];
        }
      }
      throw 'Something went wrong';
    }
  }
}
