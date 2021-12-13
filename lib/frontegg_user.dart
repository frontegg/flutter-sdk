import 'package:frontegg/auth/auth_api.dart';

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
  AuthApi _api = AuthApi();

  FronteggUser();

  Future<bool> loginPassword(String email, String password) async {
    try {
      this.email = email;
      setUserInfo(await _api.loginPassword(email, password));
      return true;
    } catch (e) {
      throw 'Invalid authentication';
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      return await _api.forgotPassword(email);
    } catch (e) {
      throw 'Invalid authentication';
    }
  }

  Future<void> setUserInfo(dynamic data) async {
    try {
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
    } catch (e) {
      throw 'Loading user error';
    }
  }

  Future<bool> loginCode(String email) async {
    try {
      this.email = email;
      return await _api.loginCode(email);
    } catch (e) {
      throw 'Invalid authentication';
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
      throw 'Invalid authentication';
    }
  }
}
