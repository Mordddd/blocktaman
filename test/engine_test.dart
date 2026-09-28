import 'package:blocktaman_app/game_engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog has 31 stable orientations', () {
    expect(catalog, hasLength(31));
    expect(catalog.map((piece) => piece.id).toSet(), hasLength(31));
  });

  test('invalid placement changes nothing', () {
    final state = GameState.fresh(42);
    final result = commitMove(state, const Move(slot: 0, row: -1, col: 0));
    expect(result.valid, isFalse);
    expect(identical(result.state, state), isTrue);
  });

  test('placement scores five points per cell without a line', () {
    final state = GameState.fresh(42);
    final result = commitMove(state, const Move(slot: 0, row: 0, col: 0));
    expect(result.valid, isTrue);
    expect(result.scoreDelta, state.tray[0].size * 5);
  });

  test('xorshift has reproducible sequence', () {
    final a = XorShift32(123);
    final b = XorShift32(123);
    expect(
      List.generate(8, (_) => a.next()),
      List.generate(8, (_) => b.next()),
    );
  });
}
