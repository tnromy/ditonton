import 'dart:io';

import 'package:core/data/db/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper helper;

  setUpAll(sqfliteFfiInit);

  setUp(() {
    helper = DatabaseHelper(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() async => (await helper.database).close());

  const movie = {
    'id': 1,
    'title': 'Spider-Man',
    'overview': 'overview',
    'posterPath': '/poster.jpg',
  };
  const tv = {
    'id': 2,
    'name': 'Game of Thrones',
    'overview': 'overview',
    'posterPath': '/poster.jpg',
  };

  group('movie watchlist', () {
    test('should insert, find, list and remove a movie', () async {
      expect(await helper.insertMovieWatchlist(movie), 1);
      expect(await helper.getMovieById(1), movie);
      expect(await helper.getWatchlistMovies(), [movie]);

      expect(await helper.removeMovieWatchlist(1), 1);
      expect(await helper.getMovieById(1), isNull);
      expect(await helper.getWatchlistMovies(), isEmpty);
    });
  });

  group('tv watchlist', () {
    test('should insert, find, list and remove a tv series', () async {
      expect(await helper.insertTvWatchlist(tv), 2);
      expect(await helper.getTvById(2), tv);
      expect(await helper.getWatchlistTv(), [tv]);

      expect(await helper.removeTvWatchlist(2), 1);
      expect(await helper.getTvById(2), isNull);
      expect(await helper.getWatchlistTv(), isEmpty);
    });
  });

  test('should reuse the same database instance', () async {
    expect(identical(await helper.database, await helper.database), isTrue);
  });

  test('should add the tv table when upgrading from version 1', () async {
    final dir = await Directory.systemTemp.createTemp('ditonton_db');
    final path = '${dir.path}/ditonton.db';
    final v1 = await databaseFactoryFfiNoIsolate.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE watchlist (id INTEGER PRIMARY KEY, title TEXT, '
          'overview TEXT, posterPath TEXT)',
        ),
      ),
    );
    await v1.close();

    final upgraded = DatabaseHelper(
      factory: databaseFactoryFfiNoIsolate,
      path: path,
    );
    expect(await upgraded.insertTvWatchlist(tv), 2);
    expect(await upgraded.getWatchlistTv(), [tv]);

    await (await upgraded.database).close();
    await dir.delete(recursive: true);
  });

  test('should resolve a default path from the database factory', () async {
    final dir = await Directory.systemTemp.createTemp('ditonton_default');
    final factory = databaseFactoryFfiNoIsolate;
    await factory.setDatabasesPath(dir.path);

    final defaultHelper = DatabaseHelper(factory: factory);
    final db = await defaultHelper.database;
    expect(db.path, '${dir.path}/ditonton.db');

    await db.close();
    await dir.delete(recursive: true);
  });
}
