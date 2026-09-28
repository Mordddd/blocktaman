import 'dart:math' as math;

const int boardSize = 8;

typedef Cell = ({int row, int col});

class Piece {
  const Piece(this.id, this.cells);
  final String id;
  final List<Cell> cells;
  int get size => cells.length;
}

class Move {
  const Move({required this.slot, required this.row, required this.col});
  final int slot;
  final int row;
  final int col;
}

class GameState {
  const GameState({
    required this.board,
    required this.tray,
    required this.used,
    required this.score,
    required this.lines,
    required this.clearStreak,
    required this.longestStreak,
    required this.moves,
    required this.rng,
    this.finished = false,
    this.dailySequence,
    this.sequenceCursor = 0,
  });

  factory GameState.fresh(int seed) {
    final rng = XorShift32(seed);
    return GameState(
      board: List<bool>.filled(64, false),
      tray: drawTray(rng),
      used: List<bool>.filled(3, false),
      score: 0,
      lines: 0,
      clearStreak: 0,
      longestStreak: 0,
      moves: 0,
      rng: rng.state,
    );
  }

  factory GameState.daily(List<String> sequence) {
    if (sequence.length != 24 ||
        sequence.any((id) => !catalog.any((piece) => piece.id == id))) {
      throw ArgumentError.value(
        sequence,
        'sequence',
        'Daily must contain 24 catalog IDs.',
      );
    }
    final byId = {for (final piece in catalog) piece.id: piece};
    return GameState(
      board: List<bool>.filled(64, false),
      tray: sequence.take(3).map((id) => byId[id]!).toList(growable: false),
      used: List<bool>.filled(3, false),
      score: 0,
      lines: 0,
      clearStreak: 0,
      longestStreak: 0,
      moves: 0,
      rng: 1,
      dailySequence: List.unmodifiable(sequence),
      sequenceCursor: 3,
    );
  }

  final List<bool> board;
  final List<Piece> tray;
  final List<bool> used;
  final int score;
  final int lines;
  final int clearStreak;
  final int longestStreak;
  final int moves;
  final int rng;
  final bool finished;
  final List<String>? dailySequence;
  final int sequenceCursor;

  bool get isDaily => dailySequence != null;

  bool occupied(int row, int col) => board[row * boardSize + col];
  bool canPlace(Piece piece, int row, int col) => piece.cells.every((cell) {
    final r = row + cell.row;
    final c = col + cell.col;
    return r >= 0 &&
        r < boardSize &&
        c >= 0 &&
        c < boardSize &&
        !occupied(r, c);
  });

  bool get hasLegalMove {
    for (var i = 0; i < tray.length; i++) {
      if (used[i]) continue;
      for (var r = 0; r < boardSize; r++) {
        for (var c = 0; c < boardSize; c++) {
          if (canPlace(tray[i], r, c)) return true;
        }
      }
    }
    return false;
  }
}

class MoveResult {
  const MoveResult(
    this.state, {
    this.valid = true,
    this.scoreDelta = 0,
    this.cleared = const {},
  });
  final GameState state;
  final bool valid;
  final int scoreDelta;
  final Set<int> cleared;
}

MoveResult commitMove(GameState state, Move move) {
  if (state.finished ||
      move.slot < 0 ||
      move.slot > 2 ||
      state.used[move.slot]) {
    return MoveResult(state, valid: false);
  }
  final piece = state.tray[move.slot];
  if (!state.canPlace(piece, move.row, move.col)) {
    return MoveResult(state, valid: false);
  }
  final board = List<bool>.from(state.board);
  for (final cell in piece.cells) {
    board[(move.row + cell.row) * boardSize + move.col + cell.col] = true;
  }
  final fullRows = <int>{};
  final fullCols = <int>{};
  for (var i = 0; i < boardSize; i++) {
    if (List.generate(
      boardSize,
      (c) => board[i * boardSize + c],
    ).every((v) => v)) {
      fullRows.add(i);
    }
    if (List.generate(
      boardSize,
      (r) => board[r * boardSize + i],
    ).every((v) => v)) {
      fullCols.add(i);
    }
  }
  final cleared = <int>{};
  for (final r in fullRows) {
    for (var c = 0; c < boardSize; c++) {
      cleared.add(r * boardSize + c);
    }
  }
  for (final c in fullCols) {
    for (var r = 0; r < boardSize; r++) {
      cleared.add(r * boardSize + c);
    }
  }
  final lineCount = fullRows.length + fullCols.length;
  final nextStreak = lineCount > 0 ? state.clearStreak + 1 : 0;
  for (final i in cleared) {
    board[i] = false;
  }
  final placement = 5 * piece.size;
  final int linePoints =
      80 * lineCount + 40 * math.max(0, lineCount - 1).toInt();
  final int clearPoints = lineCount == 0
      ? 0
      : linePoints * math.min(nextStreak, 5).toInt();
  final int allClear = lineCount > 0 && board.every((cell) => !cell) ? 150 : 0;
  final used = List<bool>.from(state.used)..[move.slot] = true;
  final rng = XorShift32(state.rng);
  final nextCursor =
      state.sequenceCursor + (used.every((value) => value) ? 3 : 0);
  late final List<Piece> tray;
  late final List<bool> nextUsed;
  if (used.every((value) => value) && state.dailySequence != null) {
    final ids = state.dailySequence!;
    if (state.sequenceCursor >= ids.length) {
      tray = state.tray;
      nextUsed = used;
    } else {
      final byId = {for (final candidate in catalog) candidate.id: candidate};
      tray = ids
          .skip(state.sequenceCursor)
          .take(3)
          .map((id) => byId[id]!)
          .toList(growable: false);
      nextUsed = List<bool>.filled(3, false);
    }
  } else if (used.every((value) => value)) {
    tray = drawTray(rng);
    nextUsed = List<bool>.filled(3, false);
  } else {
    tray = state.tray;
    nextUsed = used;
  }
  final draft = GameState(
    board: board,
    tray: tray,
    used: nextUsed,
    score: state.score + placement + clearPoints + allClear,
    lines: state.lines + lineCount,
    clearStreak: nextStreak,
    longestStreak: math.max(state.longestStreak, nextStreak),
    moves: state.moves + 1,
    rng: rng.state,
    dailySequence: state.dailySequence,
    sequenceCursor: nextCursor,
  );
  final next = GameState(
    board: draft.board,
    tray: draft.tray,
    used: draft.used,
    score: draft.score,
    lines: draft.lines,
    clearStreak: draft.clearStreak,
    longestStreak: draft.longestStreak,
    moves: draft.moves,
    rng: draft.rng,
    dailySequence: draft.dailySequence,
    sequenceCursor: draft.sequenceCursor,
    finished: !draft.hasLegalMove,
  );
  return MoveResult(
    next,
    scoreDelta: placement + clearPoints + allClear,
    cleared: cleared,
  );
}

class XorShift32 {
  XorShift32(int seed) : state = seed == 0 ? 0x6D2B79F5 : seed & 0xFFFFFFFF;
  int state;
  int next() {
    var x = state;
    x = (x ^ ((x << 13) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    x = (x ^ (x >> 17)) & 0xFFFFFFFF;
    x = (x ^ ((x << 5) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    return state = x;
  }
}

final List<Piece> catalog = _catalog();

List<Piece> drawTray(XorShift32 rng) =>
    List.generate(3, (_) => catalog[rng.next() % catalog.length]);

List<Piece> _catalog() {
  final definitions = <String, List<List<Cell>>>{
    'P1': [
      [(row: 0, col: 0)],
    ],
    'I2': [
      [(row: 0, col: 0), (row: 0, col: 1)],
      [(row: 0, col: 0), (row: 1, col: 0)],
    ],
    'I3': [
      [(row: 0, col: 0), (row: 0, col: 1), (row: 0, col: 2)],
      [(row: 0, col: 0), (row: 1, col: 0), (row: 2, col: 0)],
    ],
    'L3': [
      [(row: 0, col: 0), (row: 1, col: 0), (row: 1, col: 1)],
      [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 0)],
      [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 1)],
      [(row: 0, col: 1), (row: 1, col: 0), (row: 1, col: 1)],
    ],
    'O4': [
      [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 0), (row: 1, col: 1)],
    ],
    'I4': [
      [(row: 0, col: 0), (row: 0, col: 1), (row: 0, col: 2), (row: 0, col: 3)],
      [(row: 0, col: 0), (row: 1, col: 0), (row: 2, col: 0), (row: 3, col: 0)],
    ],
    'L4': [
      [(row: 0, col: 0), (row: 1, col: 0), (row: 2, col: 0), (row: 2, col: 1)],
      [(row: 0, col: 0), (row: 0, col: 1), (row: 0, col: 2), (row: 1, col: 0)],
      [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 1), (row: 2, col: 1)],
      [(row: 0, col: 2), (row: 1, col: 0), (row: 1, col: 1), (row: 1, col: 2)],
      [(row: 0, col: 1), (row: 1, col: 1), (row: 2, col: 0), (row: 2, col: 1)],
      [(row: 0, col: 0), (row: 1, col: 0), (row: 1, col: 1), (row: 1, col: 2)],
      [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 0), (row: 2, col: 0)],
      [(row: 0, col: 0), (row: 0, col: 1), (row: 0, col: 2), (row: 1, col: 2)],
    ],
    'T4': [
      [(row: 0, col: 0), (row: 0, col: 1), (row: 0, col: 2), (row: 1, col: 1)],
      [(row: 0, col: 1), (row: 1, col: 0), (row: 1, col: 1), (row: 2, col: 1)],
      [(row: 0, col: 1), (row: 1, col: 0), (row: 1, col: 1), (row: 1, col: 2)],
      [(row: 0, col: 0), (row: 1, col: 0), (row: 1, col: 1), (row: 2, col: 0)],
    ],
    'Z4': [
      [(row: 0, col: 0), (row: 0, col: 1), (row: 1, col: 1), (row: 1, col: 2)],
      [(row: 0, col: 1), (row: 1, col: 0), (row: 1, col: 1), (row: 2, col: 0)],
      [(row: 0, col: 1), (row: 0, col: 2), (row: 1, col: 0), (row: 1, col: 1)],
      [(row: 0, col: 0), (row: 1, col: 0), (row: 1, col: 1), (row: 2, col: 1)],
    ],
    'I5': [
      [
        (row: 0, col: 0),
        (row: 0, col: 1),
        (row: 0, col: 2),
        (row: 0, col: 3),
        (row: 0, col: 4),
      ],
      [
        (row: 0, col: 0),
        (row: 1, col: 0),
        (row: 2, col: 0),
        (row: 3, col: 0),
        (row: 4, col: 0),
      ],
    ],
    'O9': [
      [
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
    ],
  };
  final pieces = <Piece>[];
  definitions.forEach((family, shapes) {
    for (var i = 0; i < shapes.length; i++) {
      pieces.add(Piece('$family-${i + 1}', shapes[i]));
    }
  });
  assert(pieces.length == 31);
  return pieces;
}
