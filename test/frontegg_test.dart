import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/frontegg_class.dart';

void main() {
  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    Frontegg frontegg = Frontegg('baseUrl', 'imageUrl');
    expect(frontegg, isNotNull);
  });
}
