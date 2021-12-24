import 'package:flutter/material.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';
import 'package:frontegg/auth/screens/mfa/recover_mfa.dart';
import 'package:frontegg/auth/widget/code_input_container.dart';
import 'package:frontegg/auth/widget/logo.dart';
import 'package:frontegg/locatization.dart';

class TwoFactor extends StatefulWidget {
  const TwoFactor({Key? key}) : super(key: key);

  @override
  _TwoFactorState createState() => _TwoFactorState();
}

class _TwoFactorState extends State<TwoFactor> {
  String? error;
  bool loading = false;
  final AuthApi _api = AuthApi();
  bool isChecked = false;
  List<InputCode> codeDigits = List.generate(6, (index) => InputCode(FocusNode(), TextEditingController()));

  @override
  Widget build(BuildContext context) {
    List<Widget> codeInputs = List.generate(6, (index) {
      return CodeInputContainer(index, codeDigits, clearError: () {
        setState(() {
          error = null;
        });
      });
    });
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Logo(),
          const SizedBox(height: 30),
          Text(
            tr('twofactor_authentication'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 30),
          Text(tr('enter_code_from_app'), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: codeInputs),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                checkColor: Colors.white,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),
              Text(tr('dont_ask_for_365_days'))
            ],
          ),
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
                    setState(() {
                      loading = true;
                    });
                    try {
                      String code = '';
                      for (final i in codeDigits) {
                        code += i.controller.text;
                      }
                      final res = await _api.mfaCheck(code, isChecked);
                      Navigator.pop(context, res);
                    } catch (e) {
                      error = e.toString();
                    }
                    loading = false;
                    setState(() {});
                  },
          ),
          const SizedBox(height: 30),
          Text(tr('having_trouble'), style: const TextStyle(fontWeight: FontWeight.bold)),
          TextButton(
              child: Text(
                tr('disable_multifactor_with_code'),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                final bool? res = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => const RecoverMFA()),
                );
                if (res != null && res == true) {
                  Navigator.pop(context);
                }
              })
        ],
      ),
    );
  }
}
