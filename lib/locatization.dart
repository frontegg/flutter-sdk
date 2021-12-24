import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

late LocalTranslations localTranslations;

String tr(String key) => LocalTranslations._translate(key);

class LocalTranslations {
  static Map<dynamic, dynamic>? _localisedValues;
  static Map<dynamic, dynamic>? _defaultLocalisedValues;
  final String? path;

  LocalTranslations(this.path) {
    getDefaultValues();
    load();
  }

  load() async {
    if (path != null) {
      final _localisedJsonContent = await rootBundle.loadString('localization/$path');
      _localisedValues = json.decode(_localisedJsonContent);
    }
  }

  static String _translate(String key) {
    if (_localisedValues != null) {
      final String? localizedValue = _localisedValues![key] as String;
      if (localizedValue?.isNotEmpty ?? false) {
        return localizedValue!;
      }
    }
    if (_defaultLocalisedValues != null) {
      final String? defaultValue = _defaultLocalisedValues![key] as String;
      if (defaultValue?.isNotEmpty ?? false) {
        return defaultValue!;
      }
    }

    return '$key not found';
  }

  getDefaultValues() {
    _defaultLocalisedValues = {
      "login": "Sign in",
      "signup": "Sign Up",
      "email": "Email",
      "enter_your_password": "Enter Your Password",
      "password": "Password",
      "forgot_password": "Forgot Password?",
      "email_and_password_are_required": 'Email and password are required',
      "required": "Required",
      "must_be_a_valid_email": "Must be a valid email",
      "dont_have_an_account": "Don't have an account?",
      "already_have_an_account": "Already have an account?",
      "something_went_wrong": "Something went wrong",
      "magic_link_error": "Authentification with Magic Link is not available on mobile devices",
      "or": "or",
      "with": "with",
      "": "",
      "": "",
      "": "",
      "": "",
      "": "",
      "": "",
      "": "",
    };
  }
}
