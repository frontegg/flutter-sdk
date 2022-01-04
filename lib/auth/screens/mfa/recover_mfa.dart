import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/auth/widget/input_field.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/locatization.dart';

class RecoverMFA extends StatefulWidget {
  const RecoverMFA({Key? key}) : super(key: key);

  @override
  _RecoverMFAState createState() => _RecoverMFAState();
}

class _RecoverMFAState extends State<RecoverMFA> {
  bool loading = false;
  String? error;
  final AuthApi _api = AuthApi(Dio());
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
            Text(
              tr('recover_MFA'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 30),
            Text(tr('enter_MFA_recovery_code')),
            const SizedBox(height: 10),
            InputField('', _controller, label: tr('code')),
            if (error != null)
              Text(
                error ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              child: Text(tr('continue')),
              onPressed: loading
                  ? null
                  : () async {
                      if (_controller.text.isEmpty) {
                        error = tr('input_code');
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
