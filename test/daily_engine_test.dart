import 'package:blocktaman_app/game_engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily starts from explicit first tray and refills in sequence', () {
    final sequence = List<String>.generate(
      24,
      (index) => catalog[index % catalog.length].id,
    );
    var state = GameState.daily(sequence);
    expect(state.tray.map((piece) => piece.id), sequence.take(3));
    for (var slot = 0; slot < 3; slot++) {
      state = commitMove(state, Move(slot: slot, row: 0, col: slot * 2)).state;
    }
    expect(state.tray.map((piece) => piece.id), sequence.skip(3).take(3));
    expect(state.sequenceCursor, 6);
  });
}
