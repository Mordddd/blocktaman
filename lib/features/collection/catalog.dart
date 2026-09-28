enum CollectionCategory { decoration, theme }

class DecorationItem {
  const DecorationItem({
    required this.id,
    required this.name,
    required this.priceLeaves,
    required this.description,
  });

  final String id;
  final String name;
  final int priceLeaves;
  final String description;
}

class BoardTheme {
  const BoardTheme({
    required this.id,
    required this.name,
    required this.priceLeaves,
    required this.description,
  });

  final String id;
  final String name;
  final int priceLeaves;
  final String description;
}

const List<DecorationItem> decorationCatalog = [
  DecorationItem(
    id: 'cactus_mini',
    name: 'Kaktus Mini',
    priceLeaves: 20,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'fern',
    name: 'Pakis',
    priceLeaves: 40,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'daisies',
    name: 'Rumpun Daisy',
    priceLeaves: 60,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'stepping_stones',
    name: 'Batu Pijakan',
    priceLeaves: 80,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'wood_bench',
    name: 'Bangku Kayu',
    priceLeaves: 100,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'lantern',
    name: 'Lentera',
    priceLeaves: 120,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'watering_corner',
    name: 'Sudut Penyiram',
    priceLeaves: 140,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'bird_bath',
    name: 'Tempat Minum Burung',
    priceLeaves: 160,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'small_pond',
    name: 'Kolam Kecil',
    priceLeaves: 180,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'maple',
    name: 'Pohon Maple',
    priceLeaves: 220,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'hammock',
    name: 'Hammock',
    priceLeaves: 260,
    description: 'Dekorasi taman satu petak.',
  ),
  DecorationItem(
    id: 'gazebo_mini',
    name: 'Gazebo Mini',
    priceLeaves: 320,
    description: 'Dekorasi taman satu petak.',
  ),
];

const List<BoardTheme> boardThemes = [
  BoardTheme(
    id: 'morning',
    name: 'Pagi',
    priceLeaves: 0,
    description: 'Tema papan gratis.',
  ),
  BoardTheme(
    id: 'sunset',
    name: 'Senja',
    priceLeaves: 180,
    description: 'Tema papan kosmetik.',
  ),
  BoardTheme(
    id: 'night',
    name: 'Malam',
    priceLeaves: 240,
    description: 'Tema papan kosmetik.',
  ),
];

final Map<String, DecorationItem> decorationById = {
  for (final item in decorationCatalog) item.id: item,
};

final Map<String, BoardTheme> themeById = {
  for (final theme in boardThemes) theme.id: theme,
};
