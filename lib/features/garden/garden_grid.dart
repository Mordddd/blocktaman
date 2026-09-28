import 'package:flutter/material.dart';

import '../collection/catalog.dart';
import 'garden_models.dart';

const _canvas = Color(0xFFF6F4EA);
const _ink = Color(0xFF23372D);
const _primary = Color(0xFF285B42);
const _primaryTint = Color(0xFFDDEBDD);
const _emptyCell = Color(0xFFCCD8C6);
const _terracotta = Color(0xFFB95735);

class GardenGrid extends StatelessWidget {
  const GardenGrid({
    super.key,
    required this.layout,
    required this.itemForId,
    required this.onSlotTap,
    this.selectedItemId,
  });

  final GardenLayout layout;
  final Map<String, DecorationItem> itemForId;
  final ValueChanged<GardenSlot> onSlotTap;
  final String? selectedItemId;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _primaryTint,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _primary.withValues(alpha: .28), width: 2),
    ),
    padding: const EdgeInsets.all(12),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gardenSize * gardenSize,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gardenSize,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final slot = GardenSlot(
          row: index ~/ gardenSize,
          column: index % gardenSize,
        );
        final placement = layout.at(slot);
        final item = placement == null ? null : itemForId[placement.itemId];
        final label =
            'Petak taman ${slot.row + 1}, ${slot.column + 1}: ${item?.name ?? 'kosong'}';
        return Semantics(
          button: true,
          label: label,
          child: ExcludeSemantics(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSlotTap(slot),
                borderRadius: BorderRadius.circular(14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: item == null ? _emptyCell : _canvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedItemId != null
                          ? _terracotta
                          : _primary.withValues(alpha: .2),
                      width: selectedItemId != null ? 2 : 1,
                    ),
                  ),
                  child: item == null
                      ? const Center(
                          child: Icon(
                            Icons.add,
                            color: _primary,
                            semanticLabel: 'Pilih petak',
                          ),
                        )
                      : GardenItemPreview(item: item),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class GardenItemPreview extends StatelessWidget {
  const GardenItemPreview({
    super.key,
    required this.item,
    this.compact = false,
  });

  final DecorationItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(compact ? 4 : 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_iconFor(item.id), color: _terracotta, size: compact ? 24 : 32),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    ),
  );
}

IconData _iconFor(String itemId) => switch (itemId) {
  'cactus_mini' => Icons.local_florist_outlined,
  'fern' => Icons.eco_outlined,
  'daisies' => Icons.filter_vintage_outlined,
  'stepping_stones' => Icons.terrain_outlined,
  'wood_bench' => Icons.chair_alt_outlined,
  'lantern' => Icons.light_outlined,
  'watering_corner' => Icons.water_drop_outlined,
  'bird_bath' => Icons.flutter_dash_outlined,
  'small_pond' => Icons.water_outlined,
  'maple' => Icons.park_outlined,
  'hammock' => Icons.weekend_outlined,
  'gazebo_mini' => Icons.home_work_outlined,
  _ => Icons.grass_outlined,
};
