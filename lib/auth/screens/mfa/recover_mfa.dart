import 'package:flutter/material.dart';
import 'package:frontegg_mobile/auth/auth_api.dart';
import 'package:frontegg_mobile/auth/widgets/input_field.dart';
import 'package:frontegg_mobile/auth/widgets/logo.dart';
import 'package:frontegg_mobile/constants.dart';
import 'package:frontegg_mobile/locatization.dart';

class RecoverMFA extends StatefulWidget {
  const RecoverMFA({Key? key}) : super(key: key);

  @override
  _RecoverMFAState createState() => _RecoverMFAState();
}

class _RecoverMFAState extends State<RecoverMFA> {
  bool loading = false;
  String? error;
  late AuthApi _api;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _api = AuthApi(dio);
    super.initState();
  }

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
            Text(tr('recover_MFA'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 30),
            Text(tr('enter_MFA_recovery_code')),
            const SizedBox(height: 10),
            InputField('', _controller, label: tr('code'), key: const Key('recoverCode')),
            if (error != null)
              Text(
                error ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              key: const Key('mfaRecover'),
              child: Text(tr('continue')),
              onPressed: loading
                  ? null
                  : () async {
                      if (_controller.text.isEmpty) {
                        setState(() {
                          error = tr('input_code');
                          loading = false;
                        });
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
