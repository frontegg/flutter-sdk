import 'package:flutter/material.dart';
import 'package:frontegg_mobile/auth/widgets/signup_button.dart';
import 'package:frontegg_mobile/models/frontegg_user.dart';
import 'package:frontegg_mobile/auth/widgets/input_field.dart';
import 'package:frontegg_mobile/l10n/locatization.dart';

class LoginWithCode extends StatefulWidget {
  final FronteggUser user;
  const LoginWithCode(this.user, {Key? key}) : super(key: key);

  @override
  LoginWithCodeState createState() => LoginWithCodeState();
}

class LoginWithCodeState extends State<LoginWithCode> {
  bool sent = false;
  String? email;
  bool loading = false;
  Widget paddings(Widget child, {bool onlyBottom = false}) {
    return Padding(padding: EdgeInsets.only(top: onlyBottom ? 0 : 30, bottom: 30), child: child);
  }

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String? error;

  @override
  Widget build(BuildContext context) {
    return !sent
        ? Column(
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
                  InputField('name@example.com', _controller,
                      label: tr('email'), key: const Key("login"), validateEmail: true, onChange: (_) {
                    setState(() {
                      error = null;
                    });
                  }),
                  onlyBottom: true),
              if (error != null)
                paddings(
                    Text(
                      error ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                    onlyBottom: true),
              ElevatedButton(
                key: const Key('send_code_button'),
                child: Text(tr('continue')),
                onPressed: () async {
                  if (_controller.text.isEmpty) {
                    error = tr('email_required');
                    loading = false;
                  } else {
                    email = _controller.text;
                    try {
                      sent = await widget.user.loginCode(_controller.text);
                      error = null;
                    } catch (e) {
                      error = e.toString();
                    }
                  }
                  setState(() {});
                },
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              paddings(Text(
                tr('check_our_email'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              )),
              paddings(Text('${tr('we_sent_code_at')} ${email ?? _controller.text}', textAlign: TextAlign.center),
                  onlyBottom: true),
              paddings(
                  Text(tr('enter_code_below'),
                      style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  onlyBottom: true),
              InputField('6-digit code', _codeController, key: const Key('input_code')),
              const SizedBox(height: 30),
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                key: const Key('login_button'),
                onPressed: loading
                    ? null
                    : () async {
                        if (_codeController.text.length != 6) {
                          error = tr('wrong_code');
                        } else {
                          setState(() {
                            loading = true;
                          });
                          try {
                            bool sent = await widget.user.checkCode(_codeController.text);
                            if (sent) {
                              if (!mounted) return;
                              Navigator.of(context).pop(widget.user.isAuthorized);
                            }
                          } catch (e) {
                            error = e.toString();
                            loading = false;
                          }
                        }
                        setState(() {});
                      },
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(tr('continue'), style: const TextStyle(fontSize: 18)),
              ),
              paddings(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tr('havent_received_it')),
                      const SizedBox(width: 5),
                      TextButton(
                        key: const Key('resend_code_button'),
                        child: Text(tr('resend_code')),
                        onPressed: () async {
                          sent = await widget.user.loginCode(email ?? _controller.text);
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  onlyBottom: true),
            ],
          );
  }
}
