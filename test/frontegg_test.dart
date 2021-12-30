import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:frontegg/auth/screens/login/login_common.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/frontegg_class.dart';
// import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// import 'frontegg_test.mocks.dart';

class MockFronteggUser extends Mock implements FronteggUser {}

class DioAdapterMock extends Mock implements HttpClientAdapter {}

// @GenerateMocks([Dio])
void main() {
  Frontegg frontegg = Frontegg('https://baseUrl', '');
  FronteggUser? user;
  // MockFronteggUser mockUser = MockFronteggUser();
  // final dioMock = MockDio();

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    Frontegg frontegg = Frontegg('', '');
    expect(frontegg, isNotNull);
  });
  // testWidgets('Login can redirect to signup and back', (WidgetTester tester) async {
  //   const String url = 'https://baseUrl/frontegg/identity/resources/configurations/v1/public';

  //   final Dio dio = Dio();
  //   DioAdapterMock dioAdapterMock = DioAdapterMock();
  //   dio.httpClientAdapter = dioAdapterMock;
  //   // when(dioMock.get(url)).thenAnswer((_) async => Response(
  //   //     requestOptions: RequestOptions(path: url), data: {"authStrategy": "EmailAndPassword"}, statusCode: 200));

  //   when(dioAdapterMock.fetch(RequestOptions(path: url), any, any))
  //       .thenAnswer((_) async => ResponseBody.fromString('{"authStrategy": "EmailAndPassword"}', 200));
  //   await tester.pumpWidget(LoginCommon(mockUser));
  //   expect(find.text('Sign in'), findsWidgets);
  // });
  // testWidgets('Can call logout', (WidgetTester tester) async {
  //    when(httpMock.get(Uri.parse('baseUrl/frontegg/identity/resources/configurations/v1/public')))
  //       .thenAnswer((_) async => http.Response('{"authStrategy": "EmailAndPassword"}', 200));
  //   user = await frontegg?.logout();
  //   expect(user, isNull);
  // });
}
