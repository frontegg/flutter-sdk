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

# Social Login and Signup

## Google

## **Android integration**

To access Google Sign-In, you'll need to make sure to [register your application](https://firebase.google.com/docs/android/setup).

You do need to enable the OAuth APIs that you want, using the [Google Cloud Platform API manager](https://console.developers.google.com/).

Make sure you've filled out all required fields in the console for [OAuth consent screen](https://console.developers.google.com/apis/credentials/consent).
Otherwise, you may encounter `APIException` errors.

## **iOS integration**

This plugin requires iOS 9.0 or higher.

1. [First register your application](https://firebase.google.com/docs/ios/setup).
2. Make sure the file you download in step 1 is named `GoogleService-Info.plist`.
3. Move or copy `GoogleService-Info.plist` into the `[my_project]/ios/Runner` directory.
4. Open Xcode, then right-click on `Runner` directory and select `Add Files to "Runner"`.
5. Select `GoogleService-Info.plist` from the file manager.
6. A dialog will show up and ask you to select the targets, select the `Runner` target.
7. Then add the `CFBundleURLTypes` attributes below into the `[my_project]/ios/Runner/Info.plist` file.

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

## Facebook

[Register your application in Facebook Developer Console](https://developers.facebook.com/). Create a new app and fill the form as requested. Select Facebook login setup and skip the 2nd & 3rd steps.

## **Android integration**

Add some string-related values to `strings.xml` file.

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">{your app name}</string>
    <string name="facebook_app_id">{your-app-id}</string>
    <string name="fb_login_protocol_scheme">fb{your-app-id}</string>
</resources>
```

Add the below permission in `AndroidManifest.xml` file after application element.
'''<uses-permission android:name="android.permission.INTERNET"/>```

Add the following meta-data element, an activity for Facebook, and activity and intent filter for Chrome Custom Tabs inside your application element

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<activity android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
<activity
  android:name="com.facebook.CustomTabActivity"
  android:exported="true">
<intent-filter>
<action android:name="android.intent.action.VIEW" />
<category android:name="android.intent.category.DEFAULT" />
<category android:name="android.intent.category.BROWSABLE" />
<data android:scheme="@string/fb_login_protocol_scheme" />
</intent-filter>
</activity>
```

Rebuild your project to cross-verify the whole configuration.

![](https://miro.medium.com/max/1400/1*r4sDKXcsC1ueUm9spSbSvQ.jpeg)
Package Name : <Your Package name>
Default Activity Class Name : <Your Package name.activity name>

You can generate a key hash using the below command in the terminal.
`keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64`

![](https://miro.medium.com/max/1400/1*ZiWpialrdx1ysXD73d_R0A.png)
Now you have to add native platforms in-app. so let's do this by a tap on Add platform button which is located at the Setting -> Basics menu

Registration Of Android Platform
![](https://miro.medium.com/max/1400/1*d_BnLgLkuSQNfQxRUrtqNA.png)

## **iOS integration**

Set ios minimal Deployment target to 10
Please add the below code in `Info.plist` file.

```xml
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>{Your Reverse Client Id}</string>
				<string>fb{Your FB App Id}</string>
			</array>
		</dict>
	</array>
	<key>FacebookAppID</key>
	<string>{Your FB App Id}</string>
	<key>FacebookDisplayName</key>
	<string>{Your FB App Name}</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
  		<string>fbapi</string>
  		<string>fbauth2</string>
	</array>
```

## Github

register app like in https://stacktiger.github.io/flutter_auth/#/github/overview?id=getting-started

## Microsoft

https://pub.dev/packages/aad_oauth

need to run with --no-sound-null-safety flag
