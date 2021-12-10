import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/frontegg_user.dart';

class ForgotPassword extends StatefulWidget {
  final FronteggUser user;
  const ForgotPassword(this.user, {Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String? error;
  bool loading = false;
  bool sended = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Widget> notSended = [
      const Padding(
        padding: EdgeInsets.only(top: 30, bottom: 30),
        child: Text(
          ' Forgot your password?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Text(
            "Enter the email address associated with your account and we'll send you a link to reset your password",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ),
      sended
          ? const Text(
              'A password reset email has been sent to your registered email address',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green),
            )
          : InputField('name@example.com', _controller, label: "Email", validateEmail: true, onChange: (_) {
              setState(() {
                error = null;
              });
            }),
      const SizedBox(height: 30),
      ElevatedButton(
        child: const Text('Remind me', style: TextStyle(fontSize: 18)),
        onPressed: () async {
          try {
            if (_controller.text.isEmpty) {
              error = 'Email is required';
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
      const Text(
        'A password reset email has been sent to your registered email address',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.green),
      )
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
