import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../game_engine/engine.dart';

class LocalStore {
  LocalStore._(this._db);
  final Database _db;

  static Future<LocalStore> open() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'blok_taman.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE sessions (id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE leaf_ledger (source_key TEXT PRIMARY KEY, amount INTEGER NOT NULL, source_type TEXT NOT NULL, created_at INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE owned_items (item_id TEXT PRIMARY KEY, acquired_at INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE garden_placements (slot_id INTEGER PRIMARY KEY, item_id TEXT UNIQUE NOT NULL)',
        );
      },
    );
    return LocalStore._(db);
  }

  Future<void> saveCasual(GameState state) => _db.insert('sessions', {
    'id': 'casual-active',
    'payload': jsonEncode(_encode(state)),
    'updated_at': DateTime.now().toUtc().millisecondsSinceEpoch,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> clearCasual() => _db.delete('sessions', where: 'id = ?', whereArgs: ['casual-active']);

  Future<GameState?> loadCasual() async {
    final rows = await _db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: ['casual-active'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return _decode(
        jsonDecode(rows.single['payload']! as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> leaves() async =>
      (await _db.rawQuery(
            'SELECT COALESCE(SUM(amount), 0) total FROM leaf_ledger',
          )).single['total']
          as int;

  Future<bool> grantLeaves({
    required String key,
    required int amount,
    required String source,
  }) async {
    if (amount <= 0) return false;
    return _db.transaction((txn) async {
      final result = await txn.insert('leaf_ledger', {
        'source_key': key,
        'amount': amount,
        'source_type': source,
        'created_at': DateTime.now().toUtc().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      return result != 0;
    });
  }

  Future<Set<String>> ownedItems() async => (await _db.query(
    'owned_items',
  )).map((row) => row['item_id']! as String).toSet();

  Future<bool> buyItem({required String itemId, required int priceLeaves}) =>
      _db.transaction((txn) async {
        final owned = await txn.query(
          'owned_items',
          where: 'item_id = ?',
          whereArgs: [itemId],
          limit: 1,
        );
        if (owned.isNotEmpty) return false;
        final total =
            (await txn.rawQuery(
                  'SELECT COALESCE(SUM(amount), 0) total FROM leaf_ledger',
                )).single['total']
                as int;
        if (total < priceLeaves) return false;
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await txn.insert('leaf_ledger', {
          'source_key': 'buy:$itemId',
          'amount': -priceLeaves,
          'source_type': 'purchase',
          'created_at': now,
        });
        await txn.insert('owned_items', {
          'item_id': itemId,
          'acquired_at': now,
        });
        return true;
      });

  Future<void> unlockStarterCactus() async => _db.insert('owned_items', {
    'item_id': 'cactus_mini',
    'acquired_at': DateTime.now().toUtc().millisecondsSinceEpoch,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<Map<int, String>> gardenPlacements() async {
    final rows = await _db.query('garden_placements');
    return {
      for (final row in rows) row['slot_id']! as int: row['item_id']! as String,
    };
  }

  Future<void> saveGardenPlacements(Map<int, String> placements) =>
      _db.transaction((txn) async {
        await txn.delete('garden_placements');
        for (final entry in placements.entries) {
          await txn.insert('garden_placements', {
            'slot_id': entry.key,
            'item_id': entry.value,
          });
        }
      });

  Map<String, Object> _encode(GameState state) => {
    'board': state.board.map((value) => value ? 1 : 0).toList(),
    'tray': state.tray.map((piece) => piece.id).toList(),
    'used': state.used,
    'score': state.score,
    'lines': state.lines,
    'streak': state.clearStreak,
    'longest': state.longestStreak,
    'moves': state.moves,
    'rng': state.rng,
    'finished': state.finished,
  };

  GameState _decode(Map<String, dynamic> json) {
    final byId = {for (final piece in catalog) piece.id: piece};
    final tray = (json['tray'] as List).map((id) => byId[id]).toList();
    if (tray.length != 3 || tray.any((piece) => piece == null)) {
      throw const FormatException();
    }
    return GameState(
      board: (json['board'] as List).map((value) => value == 1).toList(),
      tray: tray.cast<Piece>(),
      used: (json['used'] as List).cast<bool>(),
      score: json['score'] as int,
      lines: json['lines'] as int,
      clearStreak: json['streak'] as int,
      longestStreak: json['longest'] as int,
      moves: json['moves'] as int,
      rng: json['rng'] as int,
      finished: json['finished'] as bool,
    );
  }
}
