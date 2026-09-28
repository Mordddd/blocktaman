import 'package:blocktaman_app/features/collection/catalog.dart';
import 'package:blocktaman_app/features/collection/collection_widgets.dart';
import 'package:blocktaman_app/features/garden/garden_grid.dart';
import 'package:blocktaman_app/features/garden/garden_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('garden grid exposes each 3 by 3 slot as a labelled button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GardenGrid(
            layout: const GardenLayout(
              placements: [
                GardenPlacement(
                  itemId: 'fern',
                  slot: GardenSlot(row: 0, column: 0),
                ),
              ],
            ),
            itemForId: decorationById,
            onSlotTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Petak taman 1, 1: Pakis'), findsOneWidget);
    expect(find.bySemanticsLabel('Petak taman 3, 3: kosong'), findsOneWidget);
  });

  testWidgets('collection card states ownership in text as well as colour', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CollectionItemCard(
            item: DecorationItem(
              id: 'fern',
              name: 'Pakis',
              priceLeaves: 40,
              description: 'Dekorasi taman satu petak.',
            ),
            owned: true,
          ),
        ),
      ),
    );

    expect(find.text('Dimiliki'), findsOneWidget);
    expect(find.bySemanticsLabel('Pakis, Dimiliki'), findsOneWidget);
  });
}
