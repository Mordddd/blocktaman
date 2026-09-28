const int gardenSize = 3;

class GardenSlot {
  const GardenSlot({required this.row, required this.column});

  final int row;
  final int column;

  bool get isValid =>
      row >= 0 && row < gardenSize && column >= 0 && column < gardenSize;
  int get id => row * gardenSize + column;

  Map<String, Object> toJson() => {'slotId': id};

  static GardenSlot fromId(Object? value) {
    if (value is! int || value < 0 || value >= gardenSize * gardenSize) {
      throw const FormatException('slotId taman tidak valid');
    }
    return GardenSlot(row: value ~/ gardenSize, column: value % gardenSize);
  }

  @override
  bool operator ==(Object other) =>
      other is GardenSlot && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);
}

class GardenPlacement {
  const GardenPlacement({required this.itemId, required this.slot});

  final String itemId;
  final GardenSlot slot;

  Map<String, Object> toJson() => {'itemId': itemId, 'slotId': slot.id};

  factory GardenPlacement.fromJson(Map<String, Object?> json) {
    final itemId = json['itemId'];
    if (itemId is! String || itemId.isEmpty) {
      throw const FormatException('itemId taman tidak valid');
    }
    return GardenPlacement(
      itemId: itemId,
      slot: GardenSlot.fromId(json['slotId']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GardenPlacement && other.itemId == itemId && other.slot == slot;

  @override
  int get hashCode => Object.hash(itemId, slot);
}

class GardenLayout {
  const GardenLayout({this.revision = 0, this.placements = const []});

  final int revision;
  final List<GardenPlacement> placements;

  GardenPlacement? at(GardenSlot slot) {
    for (final placement in placements) {
      if (placement.slot == slot) return placement;
    }
    return null;
  }

  GardenPlacement? forItem(String itemId) {
    for (final placement in placements) {
      if (placement.itemId == itemId) return placement;
    }
    return null;
  }

  Map<String, Object> toJson() => {
    'revision': revision,
    'placements': placements
        .map((placement) => placement.toJson())
        .toList(growable: false),
  };

  factory GardenLayout.fromJson(Map<String, Object?> json) {
    final revision = json['revision'];
    final rawPlacements = json['placements'];
    if (revision is! int || revision < 0 || rawPlacements is! List) {
      throw const FormatException('layout taman tidak valid');
    }
    final placements = rawPlacements
        .map((value) {
          if (value is! Map) {
            throw const FormatException('penempatan taman tidak valid');
          }
          return GardenPlacement.fromJson(Map<String, Object?>.from(value));
        })
        .toList(growable: false);
    _validate(placements);
    return GardenLayout(revision: revision, placements: placements);
  }

  static void _validate(List<GardenPlacement> placements) {
    final itemIds = <String>{};
    final slots = <GardenSlot>{};
    for (final placement in placements) {
      if (!placement.slot.isValid ||
          !itemIds.add(placement.itemId) ||
          !slots.add(placement.slot)) {
        throw const FormatException('penempatan taman ganda atau tidak valid');
      }
    }
  }
}
