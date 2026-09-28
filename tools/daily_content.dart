import 'dart:convert';
import 'dart:io';

const _boardCells = 64;
const _catalogIds = <String>{
  'P1-1',
  'I2-1',
  'I2-2',
  'I3-1',
  'I3-2',
  'L3-1',
  'L3-2',
  'L3-3',
  'L3-4',
  'O4-1',
  'I4-1',
  'I4-2',
  'L4-1',
  'L4-2',
  'L4-3',
  'L4-4',
  'L4-5',
  'L4-6',
  'L4-7',
  'L4-8',
  'T4-1',
  'T4-2',
  'T4-3',
  'T4-4',
  'Z4-1',
  'Z4-2',
  'Z4-3',
  'Z4-4',
  'I5-1',
  'I5-2',
  'O9-1',
};

typedef _Cell = ({int row, int col});

final _shapes = <String, List<_Cell>>{
  'P1-1': [(row: 0, col: 0)],
  'I2-1': [(row: 0, col: 0), (row: 0, col: 1)],
  'I2-2': [(row: 0, col: 0), (row: 1, col: 0)],
  'I3-1': [(row: 0, col: 0), (row: 0, col: 1), (row: 0, col: 2)],
  'I3-2': [(row: 0, col: 0), (row: 1, col: 0), (row: 2, col: 0)],
  'L3-1': [(row: 0, col: 0), (row: 1, col: 0), (row: 1, col: 1)],
  'L3-2': [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 0)],
  'L3-3': [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 1)],
  'L3-4': [(row: 0, col: 1), (row: 1, col: 0), (row: 1, col: 1)],
  'O4-1': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 1, col: 0),
    (row: 1, col: 1),
  ],
  'I4-1': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 0, col: 3),
  ],
  'I4-2': [
    (row: 0, col: 0),
    (row: 1, col: 0),
    (row: 2, col: 0),
    (row: 3, col: 0),
  ],
  'L4-1': [
    (row: 0, col: 0),
    (row: 1, col: 0),
    (row: 2, col: 0),
    (row: 2, col: 1),
  ],
  'L4-2': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 1, col: 0),
  ],
  'L4-3': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 1, col: 1),
    (row: 2, col: 1),
  ],
  'L4-4': [
    (row: 0, col: 2),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 1, col: 2),
  ],
  'L4-5': [
    (row: 0, col: 1),
    (row: 1, col: 1),
    (row: 2, col: 0),
    (row: 2, col: 1),
  ],
  'L4-6': [
    (row: 0, col: 0),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 1, col: 2),
  ],
  'L4-7': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 1, col: 0),
    (row: 2, col: 0),
  ],
  'L4-8': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 1, col: 2),
  ],
  'T4-1': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 1, col: 1),
  ],
  'T4-2': [
    (row: 0, col: 1),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 2, col: 1),
  ],
  'T4-3': [
    (row: 0, col: 1),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 1, col: 2),
  ],
  'T4-4': [
    (row: 0, col: 0),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 2, col: 0),
  ],
  'Z4-1': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 1, col: 1),
    (row: 1, col: 2),
  ],
  'Z4-2': [
    (row: 0, col: 1),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 2, col: 0),
  ],
  'Z4-3': [
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 1, col: 0),
    (row: 1, col: 1),
  ],
  'Z4-4': [
    (row: 0, col: 0),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 2, col: 1),
  ],
  'I5-1': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 0, col: 3),
    (row: 0, col: 4),
  ],
  'I5-2': [
    (row: 0, col: 0),
    (row: 1, col: 0),
    (row: 2, col: 0),
    (row: 3, col: 0),
    (row: 4, col: 0),
  ],
  'O9-1': [
    (row: 0, col: 0),
    (row: 0, col: 1),
    (row: 0, col: 2),
    (row: 1, col: 0),
    (row: 1, col: 1),
    (row: 1, col: 2),
    (row: 2, col: 0),
    (row: 2, col: 1),
    (row: 2, col: 2),
  ],
};

const _sequence = <String>[
  'P1-1',
  'I2-1',
  'I2-2',
  'I3-1',
  'I3-2',
  'L3-1',
  'L3-2',
  'L3-3',
  'L3-4',
  'O4-1',
  'I4-1',
  'I4-2',
  'P1-1',
  'I2-1',
  'I2-2',
  'I3-1',
  'I3-2',
  'L3-1',
  'L3-2',
  'L3-3',
  'L3-4',
  'O4-1',
  'I4-1',
  'I4-2',
];

Map<String, dynamic> generateLocalChallenge(DateTime date) {
  final dateKey = _dateKey(date);
  final opensAt = DateTime.utc(date.year, date.month, date.day - 1, 17);
  final closesAt = opensAt.add(const Duration(days: 1));
  final sequence = List<String>.from(_sequence);
  final challenge = <String, dynamic>{
    'challengeId': 'local-$dateKey-v1',
    'dateKey': dateKey,
    'timezone': 'Asia/Jakarta',
    'rulesVersion': 1,
    'scoringVersion': 1,
    'catalogVersion': 1,
    'initialBoard': '0' * _boardCells,
    'pieceSequence': sequence,
    'opensAt': opensAt.toIso8601String(),
    'closesAt': closesAt.toIso8601String(),
    'submissionDeadline': closesAt
        .add(const Duration(days: 1))
        .toIso8601String(),
  };
  challenge['contentHash'] = _contentHash(challenge);
  return challenge;
}

List<String> validateDailyJson(String source) {
  try {
    final decoded = jsonDecode(source);
    return decoded is Map<String, dynamic>
        ? validateDailyChallenge(decoded)
        : ['Root JSON must be an object.'];
  } on FormatException catch (error) {
    return ['Invalid JSON: ${error.message}'];
  }
}

List<String> validateDailyChallenge(Map<String, dynamic> challenge) {
  final errors = <String>[];
  const required = <String>{
    'challengeId',
    'dateKey',
    'timezone',
    'rulesVersion',
    'scoringVersion',
    'catalogVersion',
    'initialBoard',
    'pieceSequence',
    'contentHash',
    'opensAt',
    'closesAt',
    'submissionDeadline',
  };
  for (final key in required) {
    if (!challenge.containsKey(key)) errors.add('Missing $key.');
  }
  if (errors.isNotEmpty) return errors;
  if (challenge.keys.any((key) => !required.contains(key))) {
    errors.add('Unexpected challenge field.');
  }
  final dateKey = challenge['dateKey'];
  if (dateKey is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateKey)) {
    errors.add('dateKey must be YYYY-MM-DD.');
  }
  if (challenge['challengeId'] != 'local-$dateKey-v1') {
    errors.add('challengeId must be local-<dateKey>-v1.');
  }
  if (challenge['timezone'] != 'Asia/Jakarta') {
    errors.add('timezone must be Asia/Jakarta.');
  }
  for (final key in ['rulesVersion', 'scoringVersion', 'catalogVersion']) {
    if (challenge[key] != 1) errors.add('$key must be 1.');
  }
  final board = challenge['initialBoard'];
  if (board is! String || !RegExp(r'^[01]{64}$').hasMatch(board)) {
    errors.add('initialBoard must contain 64 binary cells.');
  } else if (_hasFullLine(board)) {
    errors.add('initialBoard cannot contain a full row or column.');
  }
  final sequence = challenge['pieceSequence'];
  if (sequence is! List ||
      sequence.length != 24 ||
      sequence.any((id) => id is! String || !_catalogIds.contains(id))) {
    errors.add('pieceSequence must contain exactly 24 catalog shape IDs.');
  }
  final opensAt = _utc(challenge['opensAt']);
  final closesAt = _utc(challenge['closesAt']);
  final deadline = _utc(challenge['submissionDeadline']);
  if (opensAt == null || closesAt == null || deadline == null) {
    errors.add('Challenge timestamps must be UTC ISO-8601 values.');
  } else if (dateKey is String &&
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateKey)) {
    final expectedOpen = DateTime.parse(
      '$dateKey'
      'T00:00:00+07:00',
    ).toUtc();
    if (opensAt != expectedOpen ||
        closesAt != expectedOpen.add(const Duration(days: 1)) ||
        deadline != closesAt.add(const Duration(days: 1))) {
      errors.add(
        'Challenge window must follow Asia/Jakarta midnight and +24h deadline.',
      );
    }
  }
  if (challenge['contentHash'] != _contentHash(challenge)) {
    errors.add('contentHash does not match canonical payload.');
  }
  if (errors.isEmpty &&
      !_hasSolution(board as String, List<String>.from(sequence as List))) {
    errors.add('No legal 24-placement witness found within solver budget.');
  }
  return errors;
}

DateTime? _utc(Object? value) {
  if (value is! String || !value.endsWith('Z')) return null;
  try {
    return DateTime.parse(value).toUtc();
  } on FormatException {
    return null;
  }
}

bool _hasFullLine(String board) {
  for (var i = 0; i < 8; i++) {
    if (List.generate(
          8,
          (j) => board[i * 8 + j] == '1',
        ).every((full) => full) ||
        List.generate(
          8,
          (j) => board[j * 8 + i] == '1',
        ).every((full) => full)) {
      return true;
    }
  }
  return false;
}

bool _hasSolution(String initialBoard, List<String> sequence) {
  var nodes = 0;
  bool search(List<bool> board, int index) {
    if (++nodes > 100000) return false;
    if (index == sequence.length) return true;
    final shape = _shapes[sequence[index]]!;
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        if (shape.every((cell) {
          final r = row + cell.row;
          final c = col + cell.col;
          return r < 8 && c < 8 && !board[r * 8 + c];
        })) {
          final next = List<bool>.from(board);
          for (final cell in shape) {
            next[(row + cell.row) * 8 + col + cell.col] = true;
          }
          _clearLines(next);
          if (search(next, index + 1)) return true;
        }
      }
    }
    return false;
  }

  return search(initialBoard.split('').map((cell) => cell == '1').toList(), 0);
}

void _clearLines(List<bool> board) {
  final clear = <int>{};
  for (var i = 0; i < 8; i++) {
    if (List.generate(8, (j) => board[i * 8 + j]).every((cell) => cell)) {
      clear.addAll(List.generate(8, (j) => i * 8 + j));
    }
    if (List.generate(8, (j) => board[j * 8 + i]).every((cell) => cell)) {
      clear.addAll(List.generate(8, (j) => j * 8 + i));
    }
  }
  for (final cell in clear) {
    board[cell] = false;
  }
}

String _contentHash(Map<String, dynamic> challenge) {
  final payload = <String, Object?>{};
  for (final key in [
    'challengeId',
    'dateKey',
    'timezone',
    'rulesVersion',
    'scoringVersion',
    'catalogVersion',
    'initialBoard',
    'pieceSequence',
    'opensAt',
    'closesAt',
    'submissionDeadline',
  ]) {
    payload[key] = challenge[key];
  }
  return 'sha256:${_sha256(utf8.encode(jsonEncode(payload)))}';
}

String _sha256(List<int> input) {
  final bytes = List<int>.from(input);
  final bitLength = bytes.length * 8;
  bytes.add(0x80);
  while (bytes.length % 64 != 56) {
    bytes.add(0);
  }
  for (var shift = 56; shift >= 0; shift -= 8) {
    bytes.add((bitLength >> shift) & 0xff);
  }
  var h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a;
  var h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19;
  const k = [
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];
  int rotr(int value, int amount) =>
      ((value >> amount) | (value << (32 - amount))) & 0xffffffff;
  for (var offset = 0; offset < bytes.length; offset += 64) {
    final w = List<int>.filled(64, 0);
    for (var i = 0; i < 16; i++) {
      final p = offset + i * 4;
      w[i] =
          (bytes[p] << 24) |
          (bytes[p + 1] << 16) |
          (bytes[p + 2] << 8) |
          bytes[p + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }
    var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
    for (var i = 0; i < 64; i++) {
      final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
      final choice = (e & f) ^ ((~e) & g);
      final temp1 = (h + s1 + choice + k[i] + w[i]) & 0xffffffff;
      final s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
      final majority = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + majority) & 0xffffffff;
      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }
    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
    h5 = (h5 + f) & 0xffffffff;
    h6 = (h6 + g) & 0xffffffff;
    h7 = (h7 + h) & 0xffffffff;
  }
  return [
    h0,
    h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    h7,
  ].map((word) => word.toRadixString(16).padLeft(8, '0')).join();
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    stderr.writeln(
      'Usage: dart run tools/daily_content.dart generate <YYYY-MM-DD> [output] | validate <file-or-directory>',
    );
    exitCode = 64;
    return;
  }
  if (arguments.first == 'generate' && arguments.length >= 2) {
    final date = DateTime.tryParse(arguments[1]);
    if (date == null || !_dateKey(date).contains(arguments[1])) {
      stderr.writeln('Invalid date.');
      exitCode = 64;
      return;
    }
    final output = arguments.length > 2
        ? arguments[2]
        : 'local-${arguments[1]}-v1.json';
    File(output).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(generateLocalChallenge(date))}\n',
    );
    stdout.writeln(output);
    return;
  }
  if (arguments.first == 'validate' && arguments.length == 2) {
    final target = FileSystemEntity.typeSync(arguments[1]);
    final files = target == FileSystemEntityType.directory
        ? Directory(arguments[1]).listSync().whereType<File>().where(
            (file) => file.path.endsWith('.json'),
          )
        : [File(arguments[1])];
    var failed = false;
    for (final file in files) {
      final errors = validateDailyJson(file.readAsStringSync());
      if (errors.isEmpty) {
        stdout.writeln('OK ${file.path}');
      } else {
        failed = true;
        stderr.writeln('INVALID ${file.path}: ${errors.join(' ')}');
      }
    }
    exitCode = failed ? 1 : 0;
    return;
  }
  stderr.writeln('Invalid command.');
  exitCode = 64;
}
