import 'package:flutter/material.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/auth/widget/signup_button.dart';
import 'package:frontegg/auth/widget/social_buttons.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/frontegg_user.dart';
import 'package:frontegg/locatization.dart';

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
  bool sended = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> common = [
      const SizedBox(height: 100),
      const Logo(),
      Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        child: Text(
          tr('signup'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    ];
    List<Widget> notSigned = [
      SignupButton(widget.user, false),
      InputField(tr('enter_email'), _controllerEmail, label: tr('email'), validateEmail: true, onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      const SizedBox(height: 10),
      InputField(tr('enter_name'), _controllerName, label: tr('name'), onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      const SizedBox(height: 10),
      InputField(tr('enter_company_name'), _controllerCompany, label: tr('company_name'), onChange: (_) {
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
                    sended =
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
          children: [...common, if (!sended) ...notSigned, if (sended) ...signed],
        ),
      ),
    );
  }
}
