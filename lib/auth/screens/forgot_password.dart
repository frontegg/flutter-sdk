import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/frontegg_user.dart';
import 'package:frontegg/locatization.dart';

class ForgotPassword extends StatefulWidget {
  final FronteggUser user;
  const ForgotPassword(this.user, {Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String? error;
  bool loading = false;
  bool sended = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Widget> notSended = [
      Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        child: Text(
          tr('forgot_password'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Text(tr('enter_email_to_reset_password'),
            style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
      sended
          ? Text(
              tr('password_reset_email_has_been_sent'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.green),
            )
          : InputField('name@example.com', _controller, label: tr('email'), validateEmail: true, onChange: (_) {
              setState(() {
                error = null;
              });
            }),
      const SizedBox(height: 30),
      ElevatedButton(
        child: Text(tr('remind_me'), style: const TextStyle(fontSize: 18)),
        onPressed: () async {
          try {
            if (_controller.text.isEmpty) {
              error = tr('email_required');
              loading = false;
            } else {
              sended = await widget.user.forgotPassword(_controller.text);
            }
          } catch (e) {
            error = e.toString();
            loading = false;
          }
          setState(() {});
        },
      ),
    ];
    List<Widget> child = [
      const SizedBox(height: 30),
      Text(tr('password_reset_email_has_been_sent'),
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.green))
    ];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [const Logo(), if (!sended) ...notSended, if (sended) ...child],
          ),
        ),
      ),
    );
  }
}
