import 'dart:convert';

import 'package:flutter/services.dart';

class LocalDailyManifest {
  const LocalDailyManifest({
    required this.challengeId,
    required this.dateKey,
    required this.pieceSequence,
  });

  final String challengeId;
  final String dateKey;
  final List<String> pieceSequence;

  static Future<LocalDailyManifest> loadFor(DateTime date) async {
    final dateKey =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final raw = await rootBundle.loadString(
      'assets/content/daily/local-$dateKey-v1.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final sequence = (json['pieceSequence'] as List).cast<String>();
    if (sequence.length != 24) {
      throw const FormatException('Urutan daily lokal tidak valid.');
    }
    return LocalDailyManifest(
      challengeId: json['challengeId'] as String,
      dateKey: json['dateKey'] as String,
      pieceSequence: sequence,
    );
  }
}
