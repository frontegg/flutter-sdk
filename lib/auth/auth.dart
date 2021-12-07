import 'package:dio/dio.dart';
import 'package:frontegg/auth/constants.dart';

class FronteggUser {
  String? email;
  FronteggUser();

  Future<bool> login(String email) async {
    try {
      this.email = email;
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      final response = await dio
          .post('$url/frontegg/identity/resources/auth/v1/passwordless/magiclink/prelogin', data: {"email": email});

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  FronteggUser signin() {
    return this;
  }

  bool logout() {
    email = null;
    return email == null;
  }
}
