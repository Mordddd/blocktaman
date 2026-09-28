import 'package:blocktaman_app/features/collection/catalog.dart';
import 'package:blocktaman_app/features/garden/garden_controller.dart';
import 'package:blocktaman_app/features/garden/garden_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog has the specified 12 decorations and three board themes', () {
    expect(decorationCatalog, hasLength(12));
    expect(decorationCatalog.map((item) => item.id), [
      'cactus_mini',
      'fern',
      'daisies',
      'stepping_stones',
      'wood_bench',
      'lantern',
      'watering_corner',
      'bird_bath',
      'small_pond',
      'maple',
      'hammock',
      'gazebo_mini',
    ]);
    expect(
      decorationCatalog.fold<int>(0, (sum, item) => sum + item.priceLeaves),
      1700,
    );
    expect(boardThemes.map((theme) => theme.name), ['Pagi', 'Senja', 'Malam']);
    expect(boardThemes.map((theme) => theme.priceLeaves), [0, 180, 240]);
  });

  test('placing an owned item records a persistence-ready placement', () {
    final controller = GardenController(ownedItemIds: {'fern'})..select('fern');

    final result = controller.place(const GardenSlot(row: 1, column: 1));

    expect(result.status, GardenPlacementStatus.placed);
    expect(controller.layout.placements, [
      const GardenPlacement(
        itemId: 'fern',
        slot: GardenSlot(row: 1, column: 1),
      ),
    ]);
    expect(controller.layout.toJson(), {
      'revision': 1,
      'placements': [
        {'itemId': 'fern', 'slotId': 4},
      ],
    });
  });

  test('moving an item keeps its single instance', () {
    final controller = GardenController(
      ownedItemIds: {'fern'},
      layout: const GardenLayout(
        placements: [
          GardenPlacement(itemId: 'fern', slot: GardenSlot(row: 0, column: 0)),
        ],
      ),
    );

    final result = controller
        .select('fern')
        .place(const GardenSlot(row: 2, column: 2));

    expect(result.status, GardenPlacementStatus.moved);
    expect(controller.layout.placements, [
      const GardenPlacement(
        itemId: 'fern',
        slot: GardenSlot(row: 2, column: 2),
      ),
    ]);
  });

  test(
    'occupied placement needs confirmation and never silently removes an item',
    () {
      final controller = GardenController(
        ownedItemIds: {'fern', 'lantern'},
        layout: const GardenLayout(
          placements: [
            GardenPlacement(
              itemId: 'fern',
              slot: GardenSlot(row: 0, column: 0),
            ),
            GardenPlacement(
              itemId: 'lantern',
              slot: GardenSlot(row: 1, column: 1),
            ),
          ],
        ),
      )..select('fern');

      final blocked = controller.place(const GardenSlot(row: 1, column: 1));

      expect(blocked.status, GardenPlacementStatus.replacementRequired);
      expect(blocked.replacedItemId, 'lantern');
      expect(controller.layout.placements, hasLength(2));

      final replaced = controller.place(
        const GardenSlot(row: 1, column: 1),
        replace: true,
      );

      expect(replaced.status, GardenPlacementStatus.replaced);
      expect(replaced.replacedItemId, 'lantern');
      expect(controller.layout.placements, [
        const GardenPlacement(
          itemId: 'fern',
          slot: GardenSlot(row: 1, column: 1),
        ),
      ]);
      expect(controller.unplacedOwnedItemIds, {'lantern'});
    },
  );
}
