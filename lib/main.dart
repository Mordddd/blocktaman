import 'package:flutter/material.dart';

import 'core/local_store.dart';
import 'features/collection/catalog.dart';
import 'features/collection/collection_widgets.dart';
import 'features/daily/daily_manifest.dart';
import 'features/garden/garden_controller.dart';
import 'features/garden/garden_grid.dart';
import 'features/garden/garden_models.dart';
import 'game_engine/engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();
  runApp(BlokTamanApp(store: store));
}

const canvas = Color(0xFFF6F4EA);
const ink = Color(0xFF23372D);
const primary = Color(0xFF285B42);
const terracotta = Color(0xFFB95735);

class BlokTamanApp extends StatelessWidget {
  const BlokTamanApp({super.key, this.store});
  final LocalStore? store;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BLOK TAMAN',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: ink),
      ),
    ),
    home: HomeScreen(store: store),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.store});
  final LocalStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int leaves = 0;
  GameState? saved;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final store = widget.store;
    if (store == null) return;
    final result = await Future.wait([store.leaves(), store.loadCasual()]);
    if (mounted) {
      setState(() {
        leaves = result[0] as int;
        saved = result[1] as GameState?;
      });
    }
  }

  Future<void> _startDaily() async {
    try {
      final manifest = await LocalDailyManifest.loadFor(DateTime.now());
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            initial: GameState.daily(manifest.pieceSequence),
            title: 'LATIHAN HARI INI',
            dailyLabel: '${manifest.dateKey} • skor lokal',
          ),
        ),
      );
      _refresh();
    } catch (_) {
      if (mounted) {
        _notice(
          context,
          'Fixture tantangan lokal belum tersedia untuk tanggal ini.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'BLOK TAMAN',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Semantics(
                  label: '$leaves Daun',
                  child: Chip(
                    avatar: const Icon(Icons.eco_outlined, color: primary),
                    label: Text('$leaves Daun'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Susun blok. Tumbuhkan tamanmu.',
              style: TextStyle(fontSize: 17, color: Color(0xFF526258)),
            ),
            const Spacer(),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFDDEBDD),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.local_florist_outlined,
                color: primary,
                size: 70,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () async {
                  final initial =
                      saved ??
                      GameState.fresh(DateTime.now().microsecondsSinceEpoch);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GameScreen(initial: initial, store: widget.store),
                    ),
                  );
                  _refresh();
                },
                child: Text(saved == null ? 'Main Santai' : 'Lanjutkan'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _startDaily,
                child: const Text('Tantangan Hari Ini'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GardenScreen(store: widget.store),
                        ),
                      );
                      _refresh();
                    },
                    child: const Text('Taman'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CollectionScreen(store: widget.store),
                        ),
                      );
                      _refresh();
                    },
                    child: const Text('Koleksi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.initial,
    this.store,
    this.title = 'SANTAI',
    this.dailyLabel,
  });
  final GameState initial;
  final LocalStore? store;
  final String title;
  final String? dailyLabel;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState state = widget.initial;
  int? selectedSlot;
  String message = 'Pilih blok, lalu pilih petak kiri-atas tujuan.';

  Future<void> placeAt(int row, int col) async {
    final slot = selectedSlot;
    if (slot == null) return;
    final result = commitMove(state, Move(slot: slot, row: row, col: col));
    if (!result.valid) {
      setState(() => message = 'Blok belum muat di sana.');
      return;
    }
    setState(() {
      state = result.state;
      selectedSlot = null;
      message =
          '+${result.scoreDelta} poin${result.cleared.isEmpty ? '' : ' • ${result.cleared.length} petak dibersihkan'}';
    });
    if (!state.isDaily) await widget.store?.saveCasual(state);
    if (!mounted) return;
    if (result.state.finished) _showResult();
  }

  void _showResult() => showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_florist, size: 42, color: terracotta),
          const SizedBox(height: 12),
          const Text(
            'Permainan selesai',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            '${state.score} poin • ${state.lines} garis • streak terbaik ${state.longestStreak}',
          ),
          if (state.isDaily)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Latihan • skor lokal',
                style: TextStyle(color: Color(0xFF526258)),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                setState(() {
                  state = state.isDaily
                      ? GameState.daily(state.dailySequence!)
                      : GameState.fresh(DateTime.now().microsecondsSinceEpoch);
                  selectedSlot = null;
                  message = 'Permainan baru dimulai.';
                });
              },
              child: const Text('Main lagi'),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Ke Beranda'),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.pause_circle_outline),
                      tooltip: 'Kembali ke beranda',
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          if (widget.dailyLabel != null)
                            Text(
                              widget.dailyLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF526258),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'SKOR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF526258),
                          ),
                        ),
                        Text(
                          '${state.score}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  state.clearStreak > 0
                      ? 'Combo ×${state.clearStreak.clamp(1, 5)}'
                      : 'Isi baris atau kolom untuk membersihkan.',
                  style: const TextStyle(color: primary),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: BoardView(
                      state: state,
                      selected: selectedSlot == null
                          ? null
                          : state.tray[selectedSlot!],
                      onCell: placeAt,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF526258)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: PieceButton(
                          piece: state.tray[i],
                          used: state.used[i],
                          selected: selectedSlot == i,
                          onTap: state.used[i]
                              ? null
                              : () => setState(() {
                                  selectedSlot = selectedSlot == i ? null : i;
                                  message = selectedSlot == i
                                      ? 'Sekarang pilih petak kiri-atas tujuan.'
                                      : 'Pilih blok terlebih dahulu.';
                                }),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kontrol aksesibel: pilih blok → pilih petak kiri-atas.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF526258)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key, this.store});
  final LocalStore? store;
  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  GardenController? controller;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = widget.store;
    final owned = await store?.ownedItems() ?? <String>{};
    final saved = await store?.gardenPlacements() ?? <int, String>{};
    final layout = GardenLayout(
      placements: saved.entries
          .map(
            (entry) => GardenPlacement(
              itemId: entry.value,
              slot: GardenSlot.fromId(entry.key),
            ),
          )
          .toList(growable: false),
    );
    if (mounted) {
      setState(
        () =>
            controller = GardenController(ownedItemIds: owned, layout: layout),
      );
    }
  }

  Future<void> _save() async {
    final garden = controller;
    if (garden == null) return;
    await widget.store?.saveGardenPlacements({
      for (final placement in garden.layout.placements)
        placement.slot.id: placement.itemId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final garden = controller;
    if (garden == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Taman')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GardenGrid(
              layout: garden.layout,
              itemForId: decorationById,
              selectedItemId: garden.selectedItemId,
              onSlotTap: (slot) async {
                var result = garden.place(slot);
                if (result.status ==
                    GardenPlacementStatus.replacementRequired) {
                  final replace = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Ganti dekorasi?'),
                      content: Text(
                        '${decorationById[result.replacedItemId]?.name ?? 'Item ini'} akan kembali ke inventori.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Ganti'),
                        ),
                      ],
                    ),
                  );
                  if (replace == true) {
                    result = garden.place(slot, replace: true);
                  }
                }
                if (result.changed) await _save();
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text('Pilih dekorasi yang dimiliki'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: garden.ownedItemIds
                  .map(
                    (id) => ChoiceChip(
                      label: Text(decorationById[id]!.name),
                      selected: garden.selectedItemId == id,
                      onSelected: (_) => setState(() => garden.select(id)),
                    ),
                  )
                  .toList(),
            ),
            if (garden.ownedItemIds.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Koleksimu masih kosong. Main untuk mendapatkan Daun, lalu buka Kaktus Mini di Koleksi.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, this.store});
  final LocalStore? store;
  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int leaves = 0;
  Set<String> owned = {};
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = widget.store;
    if (store == null) return;
    final values = await Future.wait([store.leaves(), store.ownedItems()]);
    if (mounted) {
      setState(() {
        leaves = values[0] as int;
        owned = values[1] as Set<String>;
      });
    }
  }

  Future<void> _buy(DecorationItem item) async {
    final store = widget.store;
    if (store == null) return;
    final ok = await store.buyItem(
      itemId: item.id,
      priceLeaves: item.priceLeaves,
    );
    if (!ok && item.id == 'cactus_mini' && leaves >= 20) {
      await store.unlockStarterCactus();
    }
    await _load();
    if (mounted) {
      _notice(
        context,
        ok || item.id == 'cactus_mini'
            ? '${item.name} kini dimiliki.'
            : 'Daun belum cukup untuk ${item.name}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Koleksi • $leaves Daun')),
    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: decorationCatalog.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 160,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final item = decorationCatalog[i];
        return CollectionItemCard(
          item: item,
          owned: owned.contains(item.id),
          onTap: owned.contains(item.id) ? null : () => _buy(item),
        );
      },
    ),
  );
}

class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.state,
    required this.selected,
    required this.onCell,
  });
  final GameState state;
  final Piece? selected;
  final void Function(int, int) onCell;
  @override
  Widget build(BuildContext context) => GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 64,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 8,
      crossAxisSpacing: 3,
      mainAxisSpacing: 3,
    ),
    itemBuilder: (_, i) {
      final row = i ~/ 8;
      final col = i % 8;
      final preview = selected != null && state.canPlace(selected!, row, col);
      return Semantics(
        button: true,
        label: 'Petak ${row + 1}, ${col + 1}',
        child: InkWell(
          onTap: () => onCell(row, col),
          borderRadius: BorderRadius.circular(6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: state.board[i]
                  ? primary
                  : preview
                  ? const Color(0xFFB7D2B8)
                  : const Color(0xFFCCD8C6),
              borderRadius: BorderRadius.circular(5),
              border: preview ? Border.all(color: primary, width: 2) : null,
            ),
          ),
        ),
      );
    },
  );
}

class PieceButton extends StatelessWidget {
  const PieceButton({
    super.key,
    required this.piece,
    required this.used,
    required this.selected,
    required this.onTap,
  });
  final Piece piece;
  final bool used;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        'Blok ${piece.id}, ${piece.size} petak${used ? ', sudah dipakai' : ''}',
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 74),
        side: BorderSide(
          color: selected ? primary : const Color(0xFFB7C4B8),
          width: selected ? 3 : 1,
        ),
        backgroundColor: selected ? const Color(0xFFDDEBDD) : Colors.white,
      ),
      child: used
          ? const Icon(Icons.check, color: primary)
          : PiecePreview(piece: piece),
    ),
  );
}

class PiecePreview extends StatelessWidget {
  const PiecePreview({super.key, required this.piece});
  final Piece piece;
  @override
  Widget build(BuildContext context) {
    final maxRow = piece.cells.map((e) => e.row).reduce(_max);
    final maxCol = piece.cells.map((e) => e.col).reduce(_max);
    return SizedBox(
      width: 48,
      height: 42,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: (maxRow + 1) * (maxCol + 1),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: maxCol + 1,
        ),
        itemBuilder: (_, i) {
          final cell = (row: i ~/ (maxCol + 1), col: i % (maxCol + 1));
          return Padding(
            padding: const EdgeInsets.all(1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: piece.cells.contains(cell)
                    ? terracotta
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }
}

int _max(int a, int b) => a > b ? a : b;
void _notice(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
