import 'dart:convert';

import 'package:frontegg/auth/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FronteggUser {
  String? email;
  String? name;
  String? profilePictureUrl;
  bool? _activatedForTenant;
  DateTime? _createdAt;
  String? _id;
  bool? _isLocked;
  DateTime? _lastLogin;
  dynamic _metadata;
  bool? _mfaEnrolled;
  dynamic _permissions;
  String? phoneNumber;
  String? _provider;
  dynamic _roles;
  String? _sub;
  String? _tenantId;
  dynamic _tenantIds;
  dynamic _tenants;
  bool? verified;
  bool isAuthorized = false;

  FronteggUser();

  Future<bool> loginPassword(String email, String password) async {
    try {
      this.email = email;
      var response = await http.post(Uri.parse('$url/frontegg/identity/resources/auth/v1/user'),
          body: jsonEncode({"email": email, "password": password}), headers: {'Content-type': 'application/json'});
      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['errors'][0];
      } else {
        final data = jsonDecode(response.body);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('accessToken', data['accessToken']);
        prefs.setString('expires', data['expires']);
        prefs.setInt('expiresIn', data['expiresIn']);
        prefs.setBool('mfaRequired', data['mfaRequired']);
        prefs.setString('refreshToken', data['refreshToken']);
        await getUserInfo();
      }
      return true;
    } catch (e) {
      print(e);
      throw 'Invalid authentication';
    }
  }

  Future<void> getUserInfo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');
      var response = await http.get(Uri.parse('$url/frontegg/identity/resources/users/v2/me'),
          headers: {'Content-type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        name = data['name'];
        profilePictureUrl = data['profilePictureUrl'];
        _activatedForTenant = data['activatedForTenant'];
        _createdAt = DateTime.parse(data['createdAt']);
        email = data['email'];
        _id = data['id'];
        _isLocked = data['isLocked'];
        _lastLogin = DateTime.parse(data['lastLogin']);
        _metadata = data['metadata'];
        _mfaEnrolled = data['mfaEnrolled'];
        _permissions = data['permissions'];
        phoneNumber = data['phoneNumber'];
        _provider = data['provider'];
        _roles = data['roles'];
        _sub = data['sub'];
        _tenantId = data['tenantId'];
        _tenantIds = data['tenantIds'];
        _tenants = data['tenants'];
        verified = data['verified'];
        isAuthorized = true;
      } else {
        throw jsonDecode(response.body)['errors'][0];
      }
    } catch (e) {
      throw 'Loading user error';
    }
  }

  Future<bool> loginCode(String email) async {
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
          body: jsonEncode({"token": code}), headers: {'Content-type': 'application/json'});
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

  FronteggUser signin() {
    return this;
  }
}
