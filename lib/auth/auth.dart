import 'package:dio/dio.dart';
import 'package:frontegg/auth/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FronteggUser {
  String? email;
  String? name;
  String? profilePictureUrl;

  FronteggUser();

  Future<bool> login(String email) async {
    try {
      this.email = email;
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      final response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/passwordless/code/prelogin', data: {"email": email});

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkCode(String code) async {
    try {
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      final response =
          await dio.post('$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin', data: {"token": code});
      if (response.statusCode == 200) {
        // final SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString('accessToken', response.data['accessToken']);
        // prefs.setString('expires', response.data['expires']);
        // prefs.setInt('expiresIn', response.data['expiresIn']);
        // prefs.setBool('mfaRequired', response.data['mfaRequired']);
        // prefs.setString('refreshToken', response.data['refreshToken']);

        // return getUserInfo();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

//   Future<bool> getUserInfo() async {
//     try {
//       var dio = Dio();
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('accessToken');
//       dio.options.headers['content-Type'] = 'application/json';
//       dio.options.headers["Authorization"] = "Bearer " + (token ?? '');
//       final response = await dio.get('$url/frontegg/identity/resources/users/v2/me');
//       if (response.statusCode == 200) {
//         name = response.data['name'];
//         profilePictureUrl = response.data['profilePictureUrl'];

// // activatedForTenant: true
// // createdAt: "2021-12-07T09:50:30.000Z"
// // email: "ioko7613@gmail.com"
// // id: "8f8ed202-aa77-43b6-97f9-442f5e4cef1b"
// // isLocked: false
// // lastLogin: "2021-12-07T13:07:37.000Z"
// // metadata: null
// // mfaEnrolled: false
// // name: "Ira"
// // permissions: [,…]
// // phoneNumber: null
// // profilePictureUrl: "https://www.gravatar.com/avatar/cfdf2ea83695ba419380c46e3e9f546c?d=https://ui-avatars.com/api/Ira/128/random"
// // provider: "local"
// // roles: [{id: "d2e5e4e7-4bd1-44c3-a3c9-9139e5c982da", vendorId: "dcbf4fb8-b772-4fcb-9ecd-3969b1d4e094",…}]
// // sub: "8f8ed202-aa77-43b6-97f9-442f5e4cef1b"
// // tenantId: "e63a0591-2ce2-4b2e-8fca-e99eeac9e98d"
// // tenantIds: ["e63a0591-2ce2-4b2e-8fca-e99eeac9e98d"]
// // tenants: [{tenantId: "e63a0591-2ce2-4b2e-8fca-e99eeac9e98d",…}]
// // verified: true

//         return true;
//       }

//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

  FronteggUser signin() {
    return this;
  }

  bool logout() {
    email = null;
    return email == null;
  }
}
