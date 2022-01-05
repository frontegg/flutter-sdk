import 'package:flutter/material.dart';
import 'package:frontegg/auth/widgets/code_input_container.dart';
import 'package:frontegg/auth/widgets/signup_button.dart';
import 'package:frontegg/frontegg_user.dart';
import 'package:frontegg/auth/widgets/input_field.dart';
import 'package:frontegg/locatization.dart';

class LoginWithCode extends StatefulWidget {
  final FronteggUser user;
  const LoginWithCode(this.user, {Key? key}) : super(key: key);

  @override
  _LoginWithCodeState createState() => _LoginWithCodeState();
}

class _LoginWithCodeState extends State<LoginWithCode> {
  bool sended = false;
  String? email;
  bool loading = false;
  Widget paddings(Widget child, {bool onlyBottom = false}) {
    return Padding(padding: EdgeInsets.only(top: onlyBottom ? 0 : 30, bottom: 30), child: child);
  }

  List<InputCode> codeDigits = List.generate(6, (index) => InputCode(FocusNode(), TextEditingController()));
  final TextEditingController _controller = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    List<Widget> codeInputs = List.generate(6, (index) {
      return CodeInputContainer(index, codeDigits);
    });

    return !sended
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              paddings(Text(
                tr('login'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              )),
              SignupButton(widget.user, true),
              paddings(
                  InputField('name@example.com', _controller, label: tr('email'), validateEmail: true, onChange: (_) {
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
                child: Text(tr('continue')),
                onPressed: () async {
                  email = _controller.text;
                  try {
                    sended = await widget.user.loginCode(_controller.text);
                    error = null;
                  } catch (e) {
                    error = e.toString();
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: codeInputs),
              const SizedBox(height: 30),
              ElevatedButton(
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(tr('continue'), style: const TextStyle(fontSize: 18)),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                        });
                        try {
                          if (_controller.text.isEmpty) {
                            error = tr('email_required');
                            loading = false;
                          } else {
                            bool sended = await widget.user.checkCode(_controller.text);
                            if (sended) {
                              Navigator.pop(context, widget.user.isAuthorized);
                            }
                          }
                        } catch (e) {
                          error = e.toString();
                          loading = false;
                        }
                      },
              ),
              if (error != null) Text(error!),
              paddings(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tr('havent_received_it')),
                      const SizedBox(width: 5),
                      TextButton(
                        child: Text(tr('resend_code')),
                        onPressed: () async {
                          sended = await widget.user.loginCode(email ?? _controller.text);
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

class InputCode {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  InputCode(this.focusNode, this.controller);
}
