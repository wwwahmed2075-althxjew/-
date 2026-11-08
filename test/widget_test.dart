import 'package:awwab/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AWWAB home screen renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AwwabApp());
    await tester.pumpAndSettle();
    expect(find.text('أهلًا بك في آواب'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
