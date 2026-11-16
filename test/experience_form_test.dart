import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';

void main() {
  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
  }

  Future<void> pressSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  // Field order in the form: title, description, thumbnail, start, end.
  Finder field(int index) => find.byType(TextFormField).at(index);

  testWidgets('empty form shows the required field errors', (tester) async {
    await openForm(tester);
    await pressSave(tester);

    expect(find.text('Enter an experience title.'), findsOneWidget);
    expect(find.text('Enter an experience description.'), findsOneWidget);
    expect(find.text('Pick a start date.'), findsOneWidget);
  });

  testWidgets('a title with only spaces is rejected', (tester) async {
    await openForm(tester);
    await tester.enterText(field(0), '     ');
    await pressSave(tester);

    expect(find.text('Enter an experience title.'), findsOneWidget);
  });

  testWidgets('a thumbnail that is not an http or https url is rejected', (
    tester,
  ) async {
    await openForm(tester);
    await tester.enterText(field(2), 'abc');
    await pressSave(tester);

    expect(
      find.text('Enter a valid URL starting with http:// or https://'),
      findsOneWidget,
    );
  });

  testWidgets('a valid form shows the summary dialog', (tester) async {
    await openForm(tester);
    await tester.enterText(field(0), 'Flutter Internship');
    await tester.enterText(field(1), 'Built the mobile app of my portfolio.');

    // Pick the start date (the picker opens on today, so just press OK).
    await tester.ensureVisible(field(3));
    await tester.tap(field(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await pressSave(tester);

    expect(find.text('Experience added successfully!'), findsOneWidget);
    expect(find.text('Title: Flutter Internship'), findsOneWidget);
    expect(find.text('End Date: Ongoing'), findsOneWidget);
  });
}
