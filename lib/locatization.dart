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
      "continue": "Continue",
      "check_our_email": "Check your email",
      "we_sent_code_at": "We sent you a six digit code at",
      "enter_code_below": "Enter the generated 6-digit code below",
      "email_required": "Email is required",
      "havent_received_it": "Haven’t received it?",
      "resend_code": "Resend a new code",
      "twofactor_authentication": "Two-Factor authentication",
      "enter_code_from_app": "Please enter the 6 digit code from your authenticator app",
      "dont_ask_for_365_days": "Don't ask again on this device for 365 days",
      "having_trouble": "Having trouble?",
      "disable_multifactor_with_code": "Click here to disable Multi-Factor with recovery code",
      "recover_MFA": "Recover MFA",
      "enter_MFA_recovery_code": "Please enter your MFA recovery code",
      "code": "Code",
      "input_code": "Input code",
      "enter_email_to_reset_password":
          "Enter the email address associated with your account and we'll send you a link to reset your password",
      "password_reset_email_has_been_sent": "A password reset email has been sent to your registered email address",
      "remind_me": "Remind me",
      "invalid_authentication": "Invalid authentication",
      "enter_email": "Enter your email",
      "enter_name": "Enter your name",
      "name": "Name",
      "enter_company_name": "Enter your company name",
      "company_name": "Company name",
      "data_required": "All data is required",
      "thanks_for_signing_up": "Thanks for signing up!",
      "check_inbox_to_activate_account": "Please check your inbox in order to activate your account.",
      'wrong_code': "Wrong Code"
    };
  }
}
