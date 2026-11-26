import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  // Opens the form, logged in, with a fake server. [postStatus] is the status
  // the fake server gives when an experience is posted.
  Future<List<http.Request>> openForm(
    WidgetTester tester, {
    int postStatus = 201,
  }) async {
    final posts = <http.Request>[];
    final apiClient = ApiClient(
      client: MockClient((request) async {
        if (request.url.path.contains('/auth/token/')) {
          return http.Response('{"token": "test-token"}', 200);
        }
        if (request.url.path.contains('/auth/logout/')) {
          return http.Response('', 401);
        }
        final saved = {
          'id': '1',
          'title': 'Flutter Internship',
          'description': 'Built the mobile app of my portfolio.',
          'category': 'full-time',
          'thumbnail': null,
          'started_at': '2026-11-25T03:00:00Z',
          'ended_at': null,
        };
        if (request.method == 'POST') {
          posts.add(request);
          return http.Response(jsonEncode(saved), postStatus);
        }
        return http.Response(jsonEncode([saved]), 200);
      }),
    );
    final auth = AuthState(apiClient);
    await auth.login('user', 'pass');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: apiClient),
          ChangeNotifierProvider.value(value: auth),
        ],
        child: const MaterialApp(home: ExperienceFormPage()),
      ),
    );
    return posts;
  }

  Future<void> pressSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  // Field order in the form: title, description, thumbnail, end.
  Finder field(int index) => find.byType(TextFormField).at(index);

  Future<void> fillRequired(WidgetTester tester) async {
    await tester.enterText(field(0), 'Flutter Internship');
    await tester.enterText(field(1), 'Built the mobile app of my portfolio.');
  }

  testWidgets('empty form shows the required field errors', (tester) async {
    final posts = await openForm(tester);
    await pressSave(tester);

    expect(find.text('Enter an experience title.'), findsOneWidget);
    expect(find.text('Enter an experience description.'), findsOneWidget);
    expect(posts, isEmpty);
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

  testWidgets('a valid form is posted and then shows in the list', (
    tester,
  ) async {
    final posts = await openForm(tester);
    await fillRequired(tester);

    // Pick the end date (the picker opens on today, so just press OK).
    await tester.ensureVisible(field(3));
    await tester.tap(field(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await pressSave(tester);

    expect(find.text('Experience added successfully!'), findsOneWidget);
    expect(posts.single.headers['Authorization'], 'Token test-token');
    final body = jsonDecode(posts.single.body) as Map<String, dynamic>;
    expect(body['title'], 'Flutter Internship');
    expect(body['category'], 'full-time');
    expect(body['ended_at'], endsWith('Z'));
    expect(body.containsKey('started_at'), isFalse);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter Internship'), findsOneWidget);
    expect(find.text('Add Experience Form'), findsNothing);
  });

  testWidgets('a 401 clears the session and asks to log in', (tester) async {
    await openForm(tester, postStatus: 401);
    final auth = tester
        .element(find.byType(ExperienceFormPage))
        .read<AuthState>();
    await fillRequired(tester);
    await pressSave(tester);

    expect(auth.isLoggedIn, isFalse);
    expect(find.byType(ExperienceFormPage), findsNothing);
  });

  testWidgets('a 403 shows an error and keeps the form', (tester) async {
    await openForm(tester, postStatus: 403);
    await fillRequired(tester);
    await pressSave(tester);

    expect(
      find.text('Your account is not allowed to add experience.'),
      findsOneWidget,
    );
    expect(find.text('Flutter Internship'), findsOneWidget);
  });
}
