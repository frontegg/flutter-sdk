import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/auth/screens/login/login_code.dart';
import 'package:frontegg/auth/screens/login/login_common.dart';
import 'package:frontegg/auth/screens/login/login_password.dart';
import 'package:frontegg/constants.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/frontegg_class.dart';
import 'package:frontegg/locatization.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'frontegg_test.mocks.dart';

class MockFronteggUser extends Mock implements FronteggUser {}

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

        final pathMe = '$url/frontegg/identity/resources/users/v2/me';
        when(_dioMock.get(pathMe)).thenAnswer((_) async =>
            Future.value(Response(requestOptions: RequestOptions(path: pathMe, method: "GET"), statusCode: 200, data: {
              'activatedForTenant': true,
              'createdAt': "2021-12-09T08:35:08.000Z",
              'email': "example@gmail.com",
              'id': "id",
              'isLocked': false,
              'lastLogin': "2022-01-05T09:28:45.000Z",
              'mfaEnrolled': false,
              'name': "name",
              'profilePictureUrl': "",
              'provider': "local",
              'tenantId': "id",
              'verified': true
            })));
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

        final path = '$url/frontegg/identity/resources/auth/v1/user';
        final data = {"email": 'example@gmail.com', "password": 'pass'};
        when(_dioMock.post(path, data: data)).thenAnswer((_) async =>
            Future.value(Response(requestOptions: RequestOptions(path: path, method: "POST"), statusCode: 200, data: {
              'accessToken': "token",
              'expires': DateTime.now().toString(),
              'expiresIn': 86400,
              'mfaRequired': false,
              'refreshToken': "refresh"
            })));

        final pathMe = '$url/frontegg/identity/resources/users/v2/me';
        when(_dioMock.get(pathMe)).thenAnswer((_) async =>
            Future.value(Response(requestOptions: RequestOptions(path: pathMe, method: "GET"), statusCode: 200, data: {
              'activatedForTenant': true,
              'createdAt': "2021-12-09T08:35:08.000Z",
              'email': "example@gmail.com",
              'id': "id",
              'isLocked': false,
              'lastLogin': "2022-01-05T09:28:45.000Z",
              'mfaEnrolled': false,
              'name': "name",
              'profilePictureUrl': "",
              'provider': "local",
              'tenantId': "id",
              'verified': true
            })));
        SharedPreferences.setMockInitialValues({});

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(mockUser.isAuthorized, true);
        expect(find.byType(LoginWithPassword), findsNothing);
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
