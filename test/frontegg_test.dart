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

import 'frontegg_test.mocks.dart';

class MockFronteggUser extends Mock implements FronteggUser {}

@GenerateMocks([Dio])
void main() {
  MockFronteggUser mockUser = MockFronteggUser();
  late MockDio _dioMock;
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
    });
    testWidgets(' password displays correct class', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/configurations/v1/public';

      when(_dioMock.options).thenReturn(BaseOptions());
      when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
          requestOptions: RequestOptions(path: path, method: "GET"),
          statusCode: 200,
          data: {"authStrategy": "EmailAndPassword"})));

      await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
      await tester.pumpAndSettle();
      expect(find.byType(LoginWithPassword), findsOneWidget);
    });
    testWidgets(' code displays correct class', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/configurations/v1/public';

      when(_dioMock.options).thenReturn(BaseOptions());
      when(_dioMock.get(path)).thenAnswer((_) async => Future.value(Response(
          requestOptions: RequestOptions(path: path, method: "GET"), statusCode: 200, data: {"authStrategy": "Code"})));

      await tester.pumpWidget(makeWidgetTestable(LoginCommon(mockUser, _dioMock)));
      await tester.pumpAndSettle();
      expect(find.byType(LoginWithCode), findsOneWidget);
    });
    testWidgets(' link sign in button', (WidgetTester tester) async {
      final path = '$url/frontegg/identity/resources/configurations/v1/public';

      when(_dioMock.options).thenReturn(BaseOptions());
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
