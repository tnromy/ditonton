import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper({this.factory, this.path});

  final DatabaseFactory? factory;
  final String? path;
  Database? _database;

  static const String tblMovieWatchlist = 'watchlist';
  static const String tblTvWatchlist = 'tv_watchlist';

  Future<Database> get database async => _database ??= await _initDb();

  Future<Database> _initDb() async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath =
        path ?? p.join(await dbFactory.getDatabasesPath(), 'ditonton.db');

    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createMovieTable(db);
    await _createTvTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTvTable(db);
    }
  }

  Future<void> _createMovieTable(Database db) => db.execute('''
    CREATE TABLE $tblMovieWatchlist (
      id INTEGER PRIMARY KEY,
      title TEXT,
      overview TEXT,
      posterPath TEXT
    );
  ''');

  Future<void> _createTvTable(Database db) => db.execute('''
    CREATE TABLE $tblTvWatchlist (
      id INTEGER PRIMARY KEY,
      name TEXT,
      overview TEXT,
      posterPath TEXT
    );
  ''');

  Future<int> insertMovieWatchlist(Map<String, dynamic> movie) =>
      _insert(tblMovieWatchlist, movie);

  Future<int> removeMovieWatchlist(int id) => _remove(tblMovieWatchlist, id);

  Future<Map<String, dynamic>?> getMovieById(int id) =>
      _findById(tblMovieWatchlist, id);

  Future<List<Map<String, dynamic>>> getWatchlistMovies() =>
      _findAll(tblMovieWatchlist);

  Future<int> insertTvWatchlist(Map<String, dynamic> tv) =>
      _insert(tblTvWatchlist, tv);

  Future<int> removeTvWatchlist(int id) => _remove(tblTvWatchlist, id);

  Future<Map<String, dynamic>?> getTvById(int id) =>
      _findById(tblTvWatchlist, id);

  Future<List<Map<String, dynamic>>> getWatchlistTv() =>
      _findAll(tblTvWatchlist);

  Future<int> _insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> _remove(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> _findById(String table, int id) async {
    final db = await database;
    final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> _findAll(String table) async {
    final db = await database;
    return db.query(table);
  }
}
