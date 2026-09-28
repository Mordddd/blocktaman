import 'garden_models.dart';

enum GardenPlacementStatus {
  placed,
  moved,
  replaced,
  unchanged,
  selectionRequired,
  itemNotOwned,
  invalidSlot,
  replacementRequired,
}

class GardenPlacementResult {
  const GardenPlacementResult(this.status, {this.replacedItemId});

  final GardenPlacementStatus status;
  final String? replacedItemId;

  bool get changed => switch (status) {
    GardenPlacementStatus.placed ||
    GardenPlacementStatus.moved ||
    GardenPlacementStatus.replaced => true,
    _ => false,
  };
}

class GardenController {
  GardenController({required Set<String> ownedItemIds, GardenLayout? layout})
    : _ownedItemIds = Set<String>.from(ownedItemIds),
      _layout = layout ?? const GardenLayout() {
    GardenLayout.fromJson(
      _layout.toJson().map((key, value) => MapEntry(key, value)),
    );
  }

  final Set<String> _ownedItemIds;
  GardenLayout _layout;
  String? selectedItemId;

  GardenLayout get layout => _layout;
  Set<String> get ownedItemIds => Set.unmodifiable(_ownedItemIds);
  Set<String> get unplacedOwnedItemIds => {
    for (final itemId in _ownedItemIds)
      if (_layout.forItem(itemId) == null) itemId,
  };

  GardenController select(String? itemId) {
    selectedItemId = itemId != null && _ownedItemIds.contains(itemId)
        ? itemId
        : null;
    return this;
  }

  GardenPlacementResult place(GardenSlot slot, {bool replace = false}) {
    if (!slot.isValid) {
      return const GardenPlacementResult(GardenPlacementStatus.invalidSlot);
    }
    final itemId = selectedItemId;
    if (itemId == null) {
      return const GardenPlacementResult(
        GardenPlacementStatus.selectionRequired,
      );
    }
    if (!_ownedItemIds.contains(itemId)) {
      return const GardenPlacementResult(GardenPlacementStatus.itemNotOwned);
    }

    final current = _layout.forItem(itemId);
    final occupied = _layout.at(slot);
    if (occupied?.itemId == itemId) {
      return const GardenPlacementResult(GardenPlacementStatus.unchanged);
    }
    if (occupied != null && !replace) {
      return GardenPlacementResult(
        GardenPlacementStatus.replacementRequired,
        replacedItemId: occupied.itemId,
      );
    }

    final next = _layout.placements
        .where(
          (placement) => placement.itemId != itemId && placement.slot != slot,
        )
        .toList();
    next.add(GardenPlacement(itemId: itemId, slot: slot));
    _layout = GardenLayout(
      revision: _layout.revision + 1,
      placements: List.unmodifiable(next),
    );
    return GardenPlacementResult(
      occupied == null
          ? (current == null
                ? GardenPlacementStatus.placed
                : GardenPlacementStatus.moved)
          : GardenPlacementStatus.replaced,
      replacedItemId: occupied?.itemId,
    );
  }
}
