import 'package:dio/dio.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:frontegg/auth/social_class.dart';
import 'package:frontegg/constants.dart';
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
      throw 'Something went wrong';
    }
  }

  Future<List<Social>> checkSocials() async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.get('$url/frontegg/identity/resources/sso/v2');
      // final List<SocialType> res = response.data.map<SocialType>((e) => SocialType.fromJson(e)).toList();

      final List<Social> res = [
        {
          "type": "github",
          "active": true,
          "customised": false,
          "clientId": null,
          "redirectUrl": "http://localhost:3000/account/social/success",
          "authorizationUrl": "/identity/resources/auth/v2/user/sso/default/github/prelogin"
        },
        {
          "type": "google",
          "active": true,
          "customised": false,
          "clientId": null,
          "redirectUrl": "http://localhost:3000/account/social/success",
          "authorizationUrl": "/identity/resources/auth/v2/user/sso/default/google/prelogin"
        },
        {
          "type": "microsoft",
          "active": true,
          "customised": false,
          "clientId": null,
          "redirectUrl": "http://localhost:3000/account/social/success",
          "authorizationUrl": "/identity/resources/auth/v2/user/sso/default/microsoft/prelogin"
        },
        {
          "type": "facebook",
          "active": true,
          "customised": false,
          "clientId": null,
          "redirectUrl": "http://localhost:3000/account/social/success",
          "authorizationUrl": "/identity/resources/auth/v2/user/sso/default/facebook/prelogin"
        },
        {
          "type": "gitlab",
          "active": true,
          "customised": false,
          "clientId": null,
          "redirectUrl": "http://localhost:3000/account/social/success",
          "authorizationUrl": "/identity/resources/auth/v2/user/sso/default/gitlab/prelogin"
        },
        {
          "type": "linkedin",
          "active": true,
          "customised": false,
          "clientId": null,
          "redirectUrl": "http://localhost:3000/account/social/success",
          "authorizationUrl": "/identity/resources/auth/v2/user/sso/default/linkedin/prelogin"
        }
      ].map<Social>((e) => Social.fromJson(e)).toList();
      return res;
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
      throw 'Invalid authentication';
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
      throw 'Invalid authentication';
    }
  }

  Future<dynamic> checkCode(String code) async {
    try {
      dio.options.headers["cookie"] = cookies?[0].split(';')[0];
      dio.options.headers['content-Type'] = 'application/json';
      print(dio.options.headers);

      var response = await dio.post(
        '$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin',
        data: {"token": code},
      );
      print('${response.statusCode} ${response.data} ${response.headers}');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', response.data['accessToken']);
      prefs.setString('expires', response.data['expires']);
      prefs.setInt('expiresIn', response.data['expiresIn']);
      prefs.setBool('mfaRequired', response.data['mfaRequired']);
      prefs.setString('refreshToken', response.data['refreshToken']);
      return await getUserInfo();
    } catch (e) {
      print(e);
      if (e is DioError && e.response != null) {
        print(e.response!.headers);
        throw e.response!.data['errors'][0] ?? 'Something went wrong';
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
  //     throw 'Invalid authentication';
  //   }
  // }

  Future<bool> loginGoogle(GoogleSignInAuthentication user) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      // var response = await dio.post(
      //     '$url/frontegg/identity/resources/auth/v1/user/sso/google/postlogin?code=4%2F0AX4XfWiVzOVvVAjU3FK-zeG7iy18ne-cbZPTK-n2e95wI7jH2XtZulfV4w27F9NLE4AHTA&state=eyJ2ZW5kb3JJZCI6ImRjYmY0ZmI4LWI3NzItNGZjYi05ZWNkLTM5NjliMWQ0ZTA5NCIsInNlc3Npb25JZCI6ImVlNzVjZGE1LTJjMmMtNGY4Yi1hODM5LTc3Y2YwZjBhZjg0NCIsImJ5dGVzIjoicnl1UW10bzlXLWdPODNMUTI5MmFKVW1Cd2RtSnFfZFl1WTBOUjBRbUpmUSJ9',
      //     data: {});

      print('google 2 ${user.hashCode}\n!!! =>${user.accessToken}\n${user.idToken}');

      var response = await dio.post(
          '$url/frontegg/identity/resources/auth/v1/user/sso/google/postlogin?code=${user.hashCode}=${user.accessToken}',
          data: {});

      final data = response.data;
      print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      if (e is DioError) {
        print(e.response!.data);
        rethrow;
      }
      throw 'Invalid authentication';
    }
  }

  Future<bool> loginGitHub(OAuthCredential creds) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      // https://ira-123.frontegg.com/frontegg/identity/resources/auth/v1/user/sso/github/postlogin?code=91c33e0e0194b65bc83e&state=eyJ2ZW5kb3JJZCI6ImRjYmY0ZmI4LWI3NzItNGZjYi05ZWNkLTM5NjliMWQ0ZTA5NCIsInNlc3Npb25JZCI6IjQyYjBjZjVjLTVjN2QtNGJkYS1iMmFlLWZiYTI5YTc3MmQ4ZiIsImJ5dGVzIjoiY2ZCSGYyTjFfNTNIUW9PMHlJME8wY015MDFYS1g1NlBNRUswQjZCWTJKVSJ9
      print('github 2 ${creds.idToken}\n===> ${creds.secret}\n===> ${creds.accessToken}');
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/user/sso/github/postlogin?code=&state=', data: {});

      final data = response.data;
      print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      if (e is DioError) {
        print(e.response!.data);
        rethrow;
      }
      throw 'Invalid authentication';
    }
  }

  Future<bool> loginFacebook(OAuthCredential creds) async {
    try {
      dio.options.headers['content-Type'] = 'application/json';
      // https://ira-123.frontegg.com/frontegg/identity/resources/auth/v1/user/sso/github/postlogin?code=91c33e0e0194b65bc83e&state=eyJ2ZW5kb3JJZCI6ImRjYmY0ZmI4LWI3NzItNGZjYi05ZWNkLTM5NjliMWQ0ZTA5NCIsInNlc3Npb25JZCI6IjQyYjBjZjVjLTVjN2QtNGJkYS1iMmFlLWZiYTI5YTc3MmQ4ZiIsImJ5dGVzIjoiY2ZCSGYyTjFfNTNIUW9PMHlJME8wY015MDFYS1g1NlBNRUswQjZCWTJKVSJ9
      print('facebook 2 ${creds.idToken}\n===> ${creds.secret}\n===> ${creds.accessToken}');
      var response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/user/sso/facebook/postlogin?code=&state=', data: {});

      final data = response.data;
      print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      if (e is DioError) {
        print(e.response!.data);
        rethrow;
      }
      throw 'Invalid authentication';
    }
  }
}
