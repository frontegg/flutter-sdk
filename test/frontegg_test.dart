import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';
import 'package:frontegg/auth/screens/login/login_common.dart';
import 'package:frontegg/auth/screens/login/login_password.dart';
import 'package:frontegg/auth/screens/mfa/mfa.dart';
import 'package:frontegg/auth/screens/mfa/recover_mfa.dart';
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
    setUp(() {
      _dioMock = MockDio();
      when(_dioMock.options).thenReturn(BaseOptions());
      mockUser = FronteggUser(dio: _dioMock);
    });
    group('Password', () {
      setUp(() {
        final path = '$url/frontegg/identity/resources/configurations/v1/public';
        when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
            requestOptions: RequestOptions(path: path, method: "GET"),
            statusCode: 200,
            data: {"authStrategy": "EmailAndPassword"})));
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
      testWidgets('displays correct class', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithPassword), findsOneWidget);
      });
      testWidgets('requres correct pass and email', (WidgetTester tester) async {
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
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
        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
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

        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
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
        await tester.pumpWidget(makeWidgetTestable(TwoFactor(_dioMock)));
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
    });
    group('Code', () {
      testWidgets('displays correct class', (WidgetTester tester) async {
        final path = '$url/frontegg/identity/resources/configurations/v1/public';

        when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
            requestOptions: RequestOptions(path: path, method: "GET"),
            statusCode: 200,
            data: {"authStrategy": "Code"})));

        await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithCode), findsOneWidget);
      });
    });

    testWidgets(' link sign in button', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/configurations/v1/public';

      when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
          requestOptions: RequestOptions(path: path, method: "GET"),
          statusCode: 200,
          data: {"authStrategy": "MagicLink"})));

      await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
      await tester.pumpAndSettle();
      expect(find.text(tr('magic_link_error')), findsOneWidget);
    });
  });

  // testWidgets('Can call logout', (WidgetTester tester) async {
  //    when(httpMock.get(Uri.parse('baseUrl/frontegg/identity/resources/configurations/v1/public')))
  //       .thenAnswer((_) async => http.Response('{"authStrategy": "EmailAndPassword"}', 200));
  //   user = await frontegg?.logout();
  //   expect(user, isNull);
  // });
}
