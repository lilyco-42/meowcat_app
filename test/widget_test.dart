import 'package:flutter_test/flutter_test.dart';
import 'package:meowcat_app/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MeowCatApp());
    expect(find.text('🐱 喵喵召唤术'), findsOneWidget);
  });
}
