import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/frontegg_class.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'frontegg_test.mocks.dart';

class MockFronteggUser extends Mock implements FronteggUser {}

class DioAdapterMock extends Mock implements HttpClientAdapter {}

@GenerateMocks([Dio])
void main() {
  // Frontegg frontegg = Frontegg('https://baseUrl', '');
  // FronteggUser? user;
  // MockFronteggUser mockUser = MockFronteggUser();
  // late DioAdapter dioAdapter;
  // late DioInterceptor dioInterceptor;
  late Dio dio;
  late MockDio _dioMock;

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    Frontegg frontegg = Frontegg('', '');
    expect(frontegg, isNotNull);
  });
  group('From Login screen', () {
    setUp(() {
      dio = Dio();
      // dioAdapter = DioAdapter(dio: dio);
      // dioInterceptor = DioInterceptor(dio: dio);
      _dioMock = MockDio();
    });
    testWidgets('Login can redirect to signup and back', (WidgetTester tester) async {
      const path = 'https://baseUrl/frontegg/identity/resources/configurations/v1/public';

      // dioAdapter
      //   ..onGet(path, (server) {
      //     print('!!!!!');
      //     server.reply(200, {"authStrategy": "EmailAndPassword"});
      //   })
      //   ..onPost(path, (server) => server.reply(200, {'message': 'success'}));

      // dioInterceptor
      //   ..onGet(
      //     path,
      //     (server) {
      //       print('!!!!!');
      //       server.reply(200, {"authStrategy": "EmailAndPassword"});
      //     },
      //     headers: {'Content-Type': 'application/json; charset=utf-8'},
      //   )
      //   ..onPost(path, (server) => server.reply(200, {'message': 'success'}));
      // print('@@@@@@@@@@@@@');

      // when(_dioMock.options).thenReturn(BaseOptions(headers: {}));
      when(_dioMock.get(path)).thenAnswer((_) {
        print('!!!!!!');
        return Future.value(Response(
            requestOptions: RequestOptions(path: path, method: "GET"), statusCode: 200, data: {'message': 'Success'}));
      });
      print('@@@@@@@@@@@@@');

      final response = await _dioMock.get(path);
      print(response.data);
      expect(response.statusCode, 200);

      // await tester.pumpWidget(LoginCommon(mockUser));
      // print('@@@@@@@@@@@@@');

      expect(find.text('Sign in'), findsWidgets);
    });
  });

  // testWidgets('Can call logout', (WidgetTester tester) async {
  //    when(httpMock.get(Uri.parse('baseUrl/frontegg/identity/resources/configurations/v1/public')))
  //       .thenAnswer((_) async => http.Response('{"authStrategy": "EmailAndPassword"}', 200));
  //   user = await frontegg?.logout();
  //   expect(user, isNull);
  // });
}
