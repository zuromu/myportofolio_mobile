import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('shows my info cards and menu buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506555400'), findsOneWidget);
    expect(find.text('View Projects'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('tapping a button shows a SnackBar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Add Project'));
    await tester.pump();

    expect(find.text('You pressed the Add Project button!'), findsOneWidget);
  });
}