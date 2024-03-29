import 'package:flutter/material.dart';
import 'package:frontegg_mobile/auth/screens/forgot_password.dart';
import 'package:frontegg_mobile/auth/widgets/input_field.dart';
import 'package:frontegg_mobile/auth/widgets/signup_button.dart';
import 'package:frontegg_mobile/models/frontegg_user.dart';
import 'package:frontegg_mobile/l10n/locatization.dart';

class LoginWithPassword extends StatefulWidget {
  final FronteggUser user;
  const LoginWithPassword(this.user, {Key? key}) : super(key: key);

  @override
  LoginWithPasswordState createState() => LoginWithPasswordState();
}

class LoginWithPasswordState extends State<LoginWithPassword> {
  bool loading = false;
  Widget paddings(Widget child, {bool onlyBottom = false}) {
    return Padding(padding: EdgeInsets.only(top: onlyBottom ? 0 : 30, bottom: 30), child: child);
  }

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        paddings(Text(
          tr('login'),
          key: const Key('loginLabel'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        )),
        SignupButton(widget.user, true),
        paddings(
          InputField('name@example.com', _controller, label: tr('email'), validateEmail: true, onChange: (_) {
            setState(() {
              error = null;
            });
          }, key: const Key('login')),
          onlyBottom: true,
        ),
        InputField(tr('enter_your_password'), _controllerPassword,
            label: tr('password'), showIcon: true, key: const Key('pass')),
        TextButton(
          key: const Key('forgot_pass_button'),
          child: Text(tr('forgot_password')),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPassword(widget.user)),
            );
          },
        ),
        if (error != null)
          paddings(
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
              onlyBottom: true),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() {
                    loading = true;
                  });
                  try {
                    if (_controller.text.isEmpty || _controllerPassword.text.isEmpty) {
                      error = tr('email_and_password_are_required');
                      loading = false;
                    } else {
                      bool sent = await widget.user.loginPassword(_controller.text, _controllerPassword.text, context);
                      if (sent) {
                        if (!mounted) return;
                        Navigator.of(context).pop(widget.user.isAuthorized);
                      }
                      loading = false;
                    }
                  } catch (e) {
                    error = e.toString();
                    loading = false;
                  }
                  setState(() {});
                },
          child: loading ? const CircularProgressIndicator() : Text(tr('login')),
        )
      ],
    );
  }
}
