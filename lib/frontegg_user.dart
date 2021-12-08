import 'dart:convert';

import 'package:frontegg/auth/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FronteggUser {
  String? email;
  late String name;
  late String profilePictureUrl;
  late bool activatedForTenant;
  late DateTime createdAt;
  late String id;
  late bool isLocked;
  late DateTime lastLogin;
  late dynamic metadata;
  late bool mfaEnrolled;
  late dynamic permissions;
  late String phoneNumber;
  late String provider;
  late dynamic roles;
  late String sub;
  late String tenantId;
  late String tenantIds;
  late dynamic tenants;
  late bool verified;

  FronteggUser();

  Future<bool> login(String email) async {
    try {
      this.email = email;
      var response = await http.post(Uri.parse('$url/frontegg/identity/resources/auth/v1/passwordless/code/prelogin'),
          body: jsonEncode({"email": email}), headers: {'Content-type': 'application/json'});
      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['errors'][0];
      }
      return true;
    } catch (e) {
      throw 'Invalid authentication';
    }
  }

  Future<bool> checkCode(String code) async {
    try {
      print(code);
      var response = await http.post(Uri.parse('$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin'),
          body: jsonEncode({"token": code}),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
          });
      print('${response.statusCode} ${response.body}');
      print(response.headers);
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('accessToken', response.data['accessToken']);
      // prefs.setString('expires', response.data['expires']);
      // prefs.setInt('expiresIn', response.data['expiresIn']);
      // prefs.setBool('mfaRequired', response.data['mfaRequired']);
      // prefs.setString('refreshToken', response.data['refreshToken']);

      // return getUserInfo();

      return response.statusCode == 200;
    } catch (e) {
      print(e);

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
