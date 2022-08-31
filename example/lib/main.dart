import 'package:flutter/material.dart';

import 'package:frontegg_mobile/frontegg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final frontegg = Frontegg("{base_url}", "{image_url}",
      gitHubSignIn: {'clientId': 'clientId', 'clientSecret': 'clientSecret'},
      microsoftConfig: {'tenant': "tenant", 'clientId': "clientId", 'redirectUri': "redirectUri"});
  FronteggUser? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (user == null)
                TextButton(
                    child: const Text('login'),
                    onPressed: () async {
                      user = await frontegg.login(context);
                      setState(() {});
                    }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user?.profilePictureUrl != null) Image.network(user?.profilePictureUrl ?? ''),
                  Column(
                    children: [
                      Text(user?.email ?? ''),
                      Text(user?.name ?? ''),
                      Text(user?.phoneNumber ?? ''),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              if (user == null)
                TextButton(
                    child: const Text('signup'),
                    onPressed: () async {
                      user = await frontegg.signup(context);
                      setState(() {});
                    }),
              if (user != null)
                TextButton(
                    child: const Text('logout'),
                    onPressed: () async {
                      user = await frontegg.logout();
                      setState(() {
                        if (user?.isAuthorized == false) {
                          user = null;
                        }
                      });
                    }),
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
