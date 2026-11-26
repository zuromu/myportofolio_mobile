import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const baseUrl = 'http://test.local';

  group('getExperiences', () {
    test('parses the list from Django', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'Flutter Internship',
                'description': 'Built a mobile app.',
                'category': 'internship',
                'thumbnail': null,
                'started_at': '2026-11-25T03:00:00Z',
                'ended_at': null,
              },
            ]),
            200,
          );
        }),
      );

      final experiences = await apiClient.getExperiences();

      expect(sent.method, 'GET');
      expect(sent.url.toString(), '$baseUrl/api/v1/experience/');
      expect(sent.headers.containsKey('Authorization'), isFalse);
      expect(experiences, hasLength(1));
      expect(experiences.first.title, 'Flutter Internship');
      expect(experiences.first.thumbnail, '');
      expect(experiences.first.startedAt, DateTime.utc(2026, 11, 25, 3));
      expect(experiences.first.endedAt, isNull);
    });

    test('throws ApiException when the server fails', () async {
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async => http.Response('error', 500)),
      );

      expect(
        apiClient.getExperiences(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('createExperience', () {
    test('sends the token and only the writable fields', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({
              'id': '2',
              'title': 'Research Assistant',
              'description': 'Helped with a paper.',
              'category': 'research',
              'thumbnail': '',
              'started_at': '2026-11-26T03:00:00Z',
              'ended_at': '2026-12-31T16:59:59Z',
            }),
            201,
          );
        }),
      );

      final created = await apiClient.createExperience(
        Experience(
          title: 'Research Assistant',
          description: 'Helped with a paper.',
          category: 'research',
          endedAt: DateTime.utc(2026, 12, 31, 16, 59, 59),
        ),
        token: 'abc123',
      );

      expect(sent.method, 'POST');
      expect(sent.url.toString(), '$baseUrl/api/v1/experience/');
      expect(sent.headers['Authorization'], 'Token abc123');
      expect(jsonDecode(sent.body), {
        'title': 'Research Assistant',
        'description': 'Helped with a paper.',
        'category': 'research',
        'thumbnail': '',
        'ended_at': '2026-12-31T16:59:59.000Z',
      });
      expect(created.id, '2');
    });

    test('throws ApiException with 401 for a dead token', () async {
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        client: MockClient(
          (request) async => http.Response('{"detail": "Invalid token."}', 401),
        ),
      );

      expect(
        apiClient.createExperience(
          const Experience(title: 'A', description: 'B', category: 'research'),
          token: 'dead',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('obtainToken', () {
    test('returns the token from Django', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          sent = request;
          return http.Response('{"token": "abc123"}', 200);
        }),
      );

      final token = await apiClient.obtainToken('ahmad', 'secret');

      expect(sent.url.toString(), '$baseUrl/api/v1/auth/token/');
      expect(jsonDecode(sent.body), {
        'username': 'ahmad',
        'password': 'secret',
      });
      expect(token, 'abc123');
    });

    test('throws ApiException with 400 for a wrong password', () async {
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        client: MockClient((request) async => http.Response('{}', 400)),
      );

      expect(
        apiClient.obtainToken('ahmad', 'wrong'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });
}
