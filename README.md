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
  hild: Text('login'),
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

## Social Login and Signup

### Google

do integration steps from https://pub.dev/packages/google_sign_in and https://console.cloud.google.com/

**Android integration**

To access Google Sign-In, you'll need to make sure to [register your application](https://firebase.google.com/docs/android/setup).

You do need to enable the OAuth APIs that you want, using the
[Google Cloud Platform API manager](https://console.developers.google.com/).

Make sure you've filled out all required fields in the console for
[OAuth consent screen](https://console.developers.google.com/apis/credentials/consent).
Otherwise, you may encounter `APIException` errors.

**iOS integration**

This plugin requires iOS 9.0 or higher.

1. [First register your application](https://firebase.google.com/docs/ios/setup).
2. Make sure the file you download in step 1 is named
   `GoogleService-Info.plist`.
3. Move or copy `GoogleService-Info.plist` into the `[my_project]/ios/Runner`
   directory.
4. Open Xcode, then right-click on `Runner` directory and select
   `Add Files to "Runner"`.
5. Select `GoogleService-Info.plist` from the file manager.
6. A dialog will show up and ask you to select the targets, select the `Runner`
   target.
7. Then add the `CFBundleURLTypes` attributes below into the
   `[my_project]/ios/Runner/Info.plist` file.

```xml
<!-- Put me in the [my_project]/ios/Runner/Info.plist file -->
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>{REVERSED_CLIENT_ID}</string>
		</array>
	</dict>
</array>
<!-- End of the Google Sign-in Section -->
```

### Facebook

also requires firebase and Register your app in the https://developers.facebook.com/ as per steps.
and setting like in quide https://medium.com/flutter-community/social-authentication-in-customized-flutter-applications-5c972bff17f3

for ios minimal Deployment target to 10

### Github

register app like in https://stacktiger.github.io/flutter_auth/#/github/overview?id=getting-started

### Microsoft

https://pub.dev/packages/aad_oauth

need to run with --no-sound-null-safety flag
