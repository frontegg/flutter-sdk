import 'package:flutter/material.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/logo.dart';

class RecoverMFA extends StatefulWidget {
  const RecoverMFA({Key? key}) : super(key: key);

  @override
  _RecoverMFAState createState() => _RecoverMFAState();
}

class _RecoverMFAState extends State<RecoverMFA> {
  bool loading = false;
  String? error;
  final AuthApi _api = AuthApi();
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Logo(),
            const SizedBox(height: 30),
            const Text(
              ' Recover MFA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 30),
            const Text('Please enter your MFA recovery code'),
            const SizedBox(height: 10),
            InputField('', _controller, label: "Code"),
            if (error != null)
              Text(
                error ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: loading
                  ? null
                  : () async {
                      if (_controller.text.isEmpty) {
                        error = "Input code";
                      } else {
                        setState(() {
                          loading = true;
                        });
                        try {
                          final res = await _api.mfaRecover(_controller.text);
                          if (res) {
                            Navigator.pop(context, true);
                          }
                        } catch (e) {
                          error = e.toString();
                        }
                        loading = false;
                        setState(() {});
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
