import 'package:flutter/material.dart';
import 'package:frontegg_mobile/auth/widgets/input_field.dart';
import 'package:frontegg_mobile/auth/widgets/logo.dart';
import 'package:frontegg_mobile/auth/widgets/signup_button.dart';
import 'package:frontegg_mobile/auth/widgets/social_buttons.dart';
import 'package:frontegg_mobile/constants.dart';
import 'package:frontegg_mobile/frontegg_user.dart';
import 'package:frontegg_mobile/locatization.dart';

class Signup extends StatefulWidget {
  final FronteggUser user;
  const Signup(this.user, {Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerCompany = TextEditingController();
  bool loading = false;
  String? error;
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> common = [
      const SizedBox(height: 100),
      const Logo(),
      Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        child: Text(
          tr('signup'),
          key: const Key('signupLabel'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    ];
    List<Widget> notSigned = [
      SignupButton(widget.user, false),
      InputField(tr('enter_email'), _controllerEmail, label: tr('email'), key: const Key('email'), validateEmail: true,
          onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      const SizedBox(height: 10),
      InputField(tr('enter_name'), _controllerName, label: tr('name'), key: const Key('name'), onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      const SizedBox(height: 10),
      InputField(tr('enter_company_name'), _controllerCompany, label: tr('company_name'), key: const Key('company'),
          onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      const SizedBox(height: 30),
      ElevatedButton(
        child: loading ? const CircularProgressIndicator() : const Text('Sign Up'),
        onPressed: loading
            ? null
            : () async {
                setState(() {
                  loading = true;
                });
                try {
                  if (_controllerEmail.text.isEmpty ||
                      _controllerName.text.isEmpty ||
                      _controllerCompany.text.isEmpty) {
                    error = tr('data_required');
                    loading = false;
                  } else {
                    sent =
                        await widget.user.signup(_controllerEmail.text, _controllerName.text, _controllerCompany.text);
                    loading = false;
                  }
                } catch (e) {
                  error = e.toString();
                  loading = false;
                }
                setState(() {});
              },
      ),
      SocialButtons(AuthType.signup, widget.user),
      const SizedBox(height: 50)
    ];

    List<Widget> signed = [
      Text(tr('thanks_for_signing_up'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      Text(
        tr('check_inbox_to_activate_account'),
        textAlign: TextAlign.center,
      )
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [...common, if (!sent) ...notSigned, if (sent) ...signed],
        ),
      ),
    );
  }
}
