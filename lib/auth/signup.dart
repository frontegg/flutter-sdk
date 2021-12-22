import 'package:flutter/material.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/auth/widget/signup_button.dart';
import 'package:frontegg/auth/widget/social_buttons.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/frontegg_user.dart';

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
      const Padding(
        padding: EdgeInsets.only(top: 30, bottom: 30),
        child: Text(
          'Sign Up',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    ];
    List<Widget> notSigned = [
      SignupButton(widget.user, false),
      InputField('Enter your email', _controllerEmail, label: "Email", validateEmail: true, onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      const SizedBox(height: 10),
      InputField('Enter your name', _controllerName, label: "Name", onChange: (_) {
        setState(() {
          error = null;
        });
      }),
      const SizedBox(height: 10),
      InputField('Enter your company name', _controllerCompany, label: "Company name", onChange: (_) {
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
                    error = 'All data is required';
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

    List<Widget> signed = const [
      Text('Thanks for signing up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 30),
      Text(
        'Please check your inbox in order to activate your account.',
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
