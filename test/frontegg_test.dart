import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';
import 'package:frontegg/auth/screens/login/login_common.dart';
import 'package:frontegg/auth/screens/login/login_password.dart';
import 'package:frontegg/auth/screens/mfa/mfa.dart';
import 'package:frontegg/auth/screens/mfa/recover_mfa.dart';
import 'package:frontegg/auth/screens/signup.dart';
import 'package:frontegg/auth/widgets/social_buttons.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/locatization.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'frontegg_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio _dioMock;
  late FronteggUser mockUser;
  logo = '';
  url = '';
  setUp(() {
    _dioMock = MockDio();
    when(_dioMock.options).thenReturn(BaseOptions());
    mockUser = FronteggUser(dioForTests: _dioMock);
    final pathMe = '$url/frontegg/identity/resources/users/v2/me';
    when(_dioMock.get(pathMe)).thenAnswer((_) async =>
        Future.value(Response(requestOptions: RequestOptions(path: pathMe, method: "GET"), statusCode: 200, data: {
          'activatedForTenant': true,
          'createdAt': DateTime.now().toString(),
          'email': "example@gmail.com",
          'id': "id",
          'isLocked': false,
          'lastLogin': DateTime.now().toString(),
          'mfaEnrolled': true,
          'name': "name",
          'profilePictureUrl': "",
          'provider': "local",
          'tenantId': "id",
          'verified': true
        })));

    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    Frontegg frontegg = Frontegg('', '');
    expect(frontegg, isNotNull);
  });

  Widget makeWidgetTestable(Widget child) {
    return MaterialApp(
      home: Material(
        child: MediaQuery(
            data: const MediaQueryData(), child: Directionality(textDirection: TextDirection.ltr, child: child)),
      ),
    );
  }

  group('From Login screen', () {
    group('Password', () {
      setUp(() {
        final path = '$url/frontegg/identity/resources/configurations/v1/public';
        when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
            requestOptions: RequestOptions(path: path, method: "GET"),
            statusCode: 200,
            data: {"authStrategy": "EmailAndPassword"})));
      });
      testWidgets('displays login screen', (WidgetTester tester) async {
        final frontegg = Frontegg("", "", dio: _dioMock);

        await tester.pumpWidget(makeWidgetTestable(
          Builder(builder: (BuildContext context) {
            return Scaffold(
              body: Column(
                children: [
                  TextButton(
                      key: const Key('button1'),
                      child: const Text('login'),
                      onPressed: () async {
                        frontegg.login(context);
                      }),
                ],
              ),
            );
          }),
        ));
        expect(find.byKey(const Key('button1')), findsOneWidget);
        await tester.tap(find.byKey(const Key('button1')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('loginLabel')), findsOneWidget);
        expect(find.byType(LoginCommon), findsWidgets);
      });
      testWidgets('displays correct class', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithPassword), findsOneWidget);
      });

      testWidgets('requres correct pass and email', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        expect(find.byType(ElevatedButton), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(find.text(tr('email_and_password_are_required')), findsWidgets);

        await tester.enterText(find.byKey(const Key("login")), "example");
        await tester.pump();
        expect(find.text(tr('must_be_a_valid_email')), findsWidgets);
      });
      testWidgets('login without mfa works correct', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key("login")), "example@gmail.com");
        await tester.enterText(find.byKey(const Key("pass")), "pass");
        await tester.pumpAndSettle();
        final pathLogin = '$url/frontegg/identity/resources/auth/v1/user';
        final data = {"email": 'example@gmail.com', "password": 'pass'};
        when(_dioMock.post(pathLogin, data: data)).thenAnswer((_) async => Future.value(
                Response(requestOptions: RequestOptions(path: pathLogin, method: "POST"), statusCode: 200, data: {
              'accessToken': "token",
              'expires': DateTime.now().toString(),
              'expiresIn': 86400,
              'mfaRequired': false,
              'refreshToken': "refresh"
            })));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(mockUser.isAuthorized, true);
        expect(find.byType(LoginWithPassword), findsNothing);
      });
      testWidgets('login with mfa works correct', (WidgetTester tester) async {
        final pathLogin = '$url/frontegg/identity/resources/auth/v1/user';
        final data = {"email": 'example@gmail.com', "password": 'pass'};
        final Response res =
            Response(requestOptions: RequestOptions(path: pathLogin, method: "POST"), statusCode: 200, data: {
          'accessToken': "token",
          'expires': DateTime.now().toString(),
          'expiresIn': 86400,
          'mfaRequired': true,
          'refreshToken': "refresh",
          'mfaToken': 'token'
        });
        when(_dioMock.post(pathLogin, data: data)).thenAnswer((_) async => Future.value(res));
        final pathCodeCheck = '$url/frontegg/identity/resources/auth/v1/user/mfa/verify';
        final dataCodeCheck = {"mfaToken": 'token', "value": '', "rememberDevice": false};
        when(_dioMock.post(pathCodeCheck, data: dataCodeCheck)).thenAnswer((_) async => Future.value(res));

        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key("login")), "example@gmail.com");
        await tester.enterText(find.byKey(const Key("pass")), "pass");
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(mockUser.isAuthorized, false);
        expect(find.byType(TwoFactor), findsOneWidget);
        await tester.tap(find.byKey(const Key('mfaCheckButton')));
        await tester.pumpAndSettle();
        expect(mockUser.isAuthorized, true);
        expect(find.byType(LoginWithPassword), findsNothing);
      });
      testWidgets('recover mfa works correct', (WidgetTester tester) async {
        final path = '$url/frontegg/identity/resources/auth/v1/user/mfa/recover';
        final data = {"recoveryCode": '123', 'email': null};
        when(_dioMock.post(path, data: data)).thenAnswer((_) async =>
            Future.value(Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200)));
        await tester.pumpWidget(makeWidgetTestable(const TwoFactor()));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('recoverMFA')));
        await tester.pumpAndSettle();
        expect(find.byType(RecoverMFA), findsOneWidget);

        expect(find.byKey(const Key('mfaRecover')), findsOneWidget);
        await tester.tap(find.byKey(const Key('mfaRecover')));
        await tester.pump();
        expect(find.text(tr('input_code')), findsWidgets);

        await tester.enterText(find.byKey(const Key("recoverCode")), "123");
        await tester.pump();
        await tester.tap(find.byKey(const Key('mfaRecover')));
        await tester.pumpAndSettle();
        expect(find.byType(TwoFactor), findsNothing);
        expect(find.byType(RecoverMFA), findsNothing);
      });
      testWidgets('can redirect to signup', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('loginLabel')), findsOneWidget);
        await tester.tap(find.byKey(const Key('redirectButton')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('signupLabel')), findsOneWidget);
      });
      testWidgets('reset password works correct', (WidgetTester tester) async {
        final path = '$url/frontegg/identity/resources/users/v1/passwords/reset';
        final data = {'email': 'example@gmail.com'};
        when(_dioMock.post(path, data: data)).thenAnswer((_) async =>
            Future.value(Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200)));

        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('forgot_pass_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('forgot_pass_button')));
        await tester.pumpAndSettle();
        expect(find.text(tr('enter_email_to_reset_password')), findsOneWidget);

        await tester.enterText(find.byKey(const Key("reset_pass_email")), "example@gmail.com");
        await tester.pump();

        await tester.tap(find.byKey(const Key('remind_button')));
        await tester.pumpAndSettle();
        expect(find.text(tr('password_reset_email_has_been_sent')), findsWidgets);
      });
    });
    group('Code', () {
      setUp(() {
        final path = '$url/frontegg/identity/resources/configurations/v1/public';
        when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
            requestOptions: RequestOptions(path: path, method: "GET"),
            statusCode: 200,
            data: {"authStrategy": "Code"})));
        final pathPrelogin = '$url/frontegg/identity/resources/auth/v1/passwordless/code/prelogin';
        when(_dioMock.post(pathPrelogin, data: {"email": 'example@gmail.com'})).thenAnswer((_) async => Future.value(
            Response(requestOptions: RequestOptions(path: pathPrelogin, method: "POST"), statusCode: 200)));
      });
      testWidgets('displays correct class', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithCode), findsOneWidget);
      });
      testWidgets('requres correct email', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('send_code_button')));
        await tester.pumpAndSettle();
        expect(find.text(tr('email_required')), findsWidgets);

        await tester.enterText(find.byKey(const Key("login")), "example");
        await tester.pumpAndSettle();
        expect(find.text(tr('must_be_a_valid_email')), findsWidgets);
      });
      testWidgets('login works correct', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key("login")), "example@gmail.com");
        await tester.pump();

        await tester.tap(find.byKey(const Key('send_code_button')));
        await tester.pumpAndSettle();
        expect(find.text(tr('enter_code_below')), findsWidgets);
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();
        expect(find.text(tr('wrong_code')), findsWidgets);
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('input_code')), "1111112");
        await tester.pump();
        expect(find.text(tr('wrong_code')), findsWidgets);

        await tester.enterText(find.byKey(const Key('input_code')), "111111");

        final pathCode = '$url/frontegg/identity/resources/auth/v1/passwordless/code/postlogin';
        final dataCode = {"token": '111111'};
        when(_dioMock.post(pathCode, data: dataCode)).thenAnswer((_) async => Future.value(
                Response(requestOptions: RequestOptions(path: pathCode, method: "POST"), statusCode: 200, data: {
              'accessToken': "token",
              'expires': DateTime.now().toString(),
              'expiresIn': 86400,
              'mfaRequired': false,
              'refreshToken': "refresh",
              'mfaToken': 'token'
            })));

        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();
        expect(mockUser.isAuthorized, true);
        expect(find.byType(LoginWithCode), findsNothing);
      });
      testWidgets('can resend code', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key("login")), "example@gmail.com");
        await tester.pump();

        await tester.tap(find.byKey(const Key('send_code_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('resend_code_button')));
        expect(find.text(tr('enter_code_below')), findsOneWidget);
      });

      testWidgets('social login displays social login buttons', (WidgetTester tester) async {
        final path = '$url/frontegg/identity/resources/sso/v2';
        when(_dioMock.get(path)).thenAnswer((_) async =>
            Future.value(Response(requestOptions: RequestOptions(path: path, method: "GET"), statusCode: 200, data: {
              {"type": "github", "active": true},
              {"type": "google", "active": true},
              {"type": "microsoft", "active": true},
              {"type": "facebook", "active": true}
            })));
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
        await tester.pumpAndSettle();
        expect(find.byType(SocialButtons), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('github')), findsOneWidget);
        expect(find.byKey(const Key('google')), findsOneWidget);
        expect(find.byKey(const Key('microsoft')), findsOneWidget);
        expect(find.byKey(const Key('facebook')), findsOneWidget);
      });
    });
    testWidgets('show error on link login', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/configurations/v1/public';

      when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
          requestOptions: RequestOptions(path: path, method: "GET"),
          statusCode: 200,
          data: {"authStrategy": "MagicLink"})));

      await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser)));
      await tester.pumpAndSettle();
      expect(find.text(tr('magic_link_error')), findsOneWidget);
    });
  });
  group('From Signup screen', () {
    testWidgets('displays signup screen', (WidgetTester tester) async {
      final frontegg = Frontegg("", "", dio: _dioMock);

      await tester.pumpWidget(makeWidgetTestable(
        Builder(builder: (BuildContext context) {
          return Scaffold(
            body: Column(
              children: [
                TextButton(
                    key: const Key('button1'),
                    child: const Text('login'),
                    onPressed: () async {
                      frontegg.signup(context);
                    }),
              ],
            ),
          );
        }),
      ));
      expect(find.byKey(const Key('button1')), findsOneWidget);
      await tester.tap(find.byKey(const Key('button1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('signupLabel')), findsOneWidget);
      expect(find.byType(Signup), findsWidgets);
    });
    testWidgets('can redirect to login', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/configurations/v1/public';
      when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
          requestOptions: RequestOptions(path: path, method: "GET"),
          statusCode: 200,
          data: {"authStrategy": "EmailAndPassword"})));
      await tester.pumpWidget(makeWidgetTestable(Signup(mockUser)));
      expect(find.byKey(const Key('signupLabel')), findsOneWidget);
      expect(find.byKey(const Key('redirectButton')), findsWidgets);
      await tester.tap(find.byKey(const Key('redirectButton')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginCommon), findsOneWidget);
    });
    testWidgets('sign up works correct', (WidgetTester tester) async {
      await tester.pumpWidget(makeWidgetTestable(Signup(mockUser)));
      await tester.enterText(find.byKey(const Key("email")), "example@gmail.com");
      await tester.enterText(find.byKey(const Key("name")), "name");
      await tester.enterText(find.byKey(const Key("company")), "company");
      await tester.pump();
      final path = '$url/frontegg/identity/resources/users/v1/signUp';
      final data = {"email": "example@gmail.com", "name": "name", "companyName": "company"};
      when(_dioMock.post(path, data: data)).thenAnswer((_) async =>
          Future.value(Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 201)));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text(tr('thanks_for_signing_up')), findsOneWidget);
    });
    testWidgets('validates field', (WidgetTester tester) async {
      await tester.pumpWidget(makeWidgetTestable(Signup(mockUser)));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text(tr('data_required')), findsOneWidget);
      await tester.enterText(find.byKey(const Key("email")), "example");
      await tester.enterText(find.byKey(const Key("name")), "name");
      await tester.enterText(find.byKey(const Key("company")), "company");
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text(tr('must_be_a_valid_email')), findsOneWidget);
    });
  });
  group('Social Login', () {
    setUp(() {
      final path = '$url/frontegg/identity/resources/sso/v2';
      when(_dioMock.get(path)).thenAnswer((_) async =>
          Future.value(Response(requestOptions: RequestOptions(path: path, method: "GET"), statusCode: 200, data: {
            {"type": "github", "active": true},
            {"type": "google", "active": true},
            {"type": "microsoft", "active": true},
            {"type": "facebook", "active": true}
          })));

      final pathRefresh = '$url/frontegg/identity/resources/auth/v1/user/token/refresh';
      when(_dioMock.post(pathRefresh)).thenAnswer((_) async => Future.value(
              Response(requestOptions: RequestOptions(path: pathRefresh, method: "POST"), statusCode: 200, data: {
            'accessToken': "token",
            'expires': DateTime.now().toString(),
            'expiresIn': 86400,
            'mfaRequired': false,
            'refreshToken': "refresh",
            'mfaToken': 'token'
          })));
    });

    testWidgets('google', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/auth/v1/user/sso/google/postlogin?access_token=token';
      final headers = Headers();
      headers.set('set-cookie', 'value');
      when(_dioMock.post(path)).thenAnswer((_) async => Future.value(
          Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200, headers: headers)));
      final res = await mockUser.socialLogin(Auth(), 'google');
      expect(res, true);
      expect(mockUser.isAuthorized, true);
    });
    testWidgets('github', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/auth/v1/user/sso/github/postlogin?access_token=token';
      final headers = Headers();
      headers.set('set-cookie', 'value');
      when(_dioMock.post(path)).thenAnswer((_) async => Future.value(
          Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200, headers: headers)));
      final res = await mockUser.socialLogin(Auth(), 'github');
      expect(res, true);
      expect(mockUser.isAuthorized, true);
    });
    testWidgets('microsoft', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/auth/v1/user/sso/microsoft/postlogin?access_token=token';
      final headers = Headers();
      headers.set('set-cookie', 'value');
      when(_dioMock.post(path)).thenAnswer((_) async => Future.value(
          Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200, headers: headers)));
      final res = await mockUser.socialLogin(Auth(), 'microsoft');
      expect(res, true);
      expect(mockUser.isAuthorized, true);
    });
    testWidgets('facebook', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/auth/v1/user/sso/facebook/postlogin?access_token=token';
      final headers = Headers();
      headers.set('set-cookie', 'value');
      when(_dioMock.post(path)).thenAnswer((_) async => Future.value(
          Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200, headers: headers)));
      final res = await mockUser.socialLogin(Auth(), 'facebook');
      expect(res, true);
      expect(mockUser.isAuthorized, true);
    });
  });
}

class Auth {
  String? accessToken;
  Auth() {
    accessToken = 'token';
  }
}
