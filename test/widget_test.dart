import 'package:blocktaman_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home offers a playable casual game', (tester) async {
    await tester.pumpWidget(const BlokTamanApp());
    expect(find.text('BLOK TAMAN'), findsOneWidget);
    expect(find.text('Main Santai'), findsOneWidget);
  });
}
