<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

import 'package:frontegg/frontegg.dart';

final frontegg = Frontegg("baseUrl", "logoImage");
FronteggUser? user;

## Usage

Login

```
TextButton(
                    child: Text('login'),
                    onPressed: () async {
                      user = await frontegg.login(context);
                      setState(() {});
                    })
```

Sign Up

```
 TextButton(
                    child: Text('signup'),
                    onPressed: () async {
                      user = await frontegg.signup(context);
                      setState(() {});
                    }),
```

Log out

```
TextButton(
                    child: Text('logout'),
                    onPressed: () async {
                      user = await frontegg.logout();
                      setState(() {
                        if (user?.isAuthorized == false) {
                          user = null;
                        }
                      });
                    }
```

User Information

```
    after login
    user?.email, user?.name, user?.phoneNumber
```

## Additional information

To login with google do integration steps from https://pub.dev/packages/google_sign_in
