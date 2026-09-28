import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tools/daily_content.dart';

void main() {
  final fixtureDirectory = Directory('assets/content/daily');

  test('the offline pack contains fourteen valid local daily challenges', () {
    final fixtures =
        fixtureDirectory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(fixtures, hasLength(14));
    for (final fixture in fixtures) {
      expect(
        validateDailyJson(fixture.readAsStringSync()),
        isEmpty,
        reason: fixture.path,
      );
    }
  });

  test('a generated local challenge has a complete, solvable sequence', () {
    final challenge = generateLocalChallenge(DateTime.utc(2026, 10, 12));

    expect(challenge['challengeId'], 'local-2026-10-12-v1');
    expect(challenge['pieceSequence'], hasLength(24));
    expect(validateDailyChallenge(challenge), isEmpty);
  });
}
