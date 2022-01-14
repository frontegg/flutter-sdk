import 'package:flutter/material.dart';
import 'package:frontegg/auth/auth_api.dart';
import 'package:frontegg/auth/screens/mfa/recover_mfa.dart';
import 'package:frontegg/auth/widgets/input_field.dart';
import 'package:frontegg/auth/widgets/logo.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/locatization.dart';

class TwoFactor extends StatefulWidget {
  const TwoFactor({Key? key}) : super(key: key);

  @override
  _TwoFactorState createState() => _TwoFactorState();
}

class _TwoFactorState extends State<TwoFactor> {
  String? error;
  bool loading = false;
  late AuthApi _api;
  bool isChecked = false;

  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    _api = AuthApi(dio);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          InputField('6-digit code', _codeController, key: const Key('input_code')),
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
            key: const Key('mfaCheckButton'),
            child: Text(tr('continue')),
            onPressed: loading
                ? null
                : () async {
                    setState(() {
                      loading = true;
                    });
                    try {
                      final res = await _api.mfaCheck(_codeController.text, isChecked);
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
              key: const Key('recoverMFA'),
              child: Text(
                tr('disable_multifactor_with_code'),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                final bool? res =
                    await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => const RecoverMFA()));
                if (res != null && res == true) {
                  Navigator.pop(context);
                }
              })
        ],
      ),
    );
  }
}
