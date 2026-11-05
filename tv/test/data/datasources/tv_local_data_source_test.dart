import 'package:core/core.dart';
import 'package:tv/data/datasources/tv_local_data_source.dart';
import 'package:tv/data/models/tv_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late TvLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    dataSource = TvLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  group('save watchlist', () {
    test(
      'should return success message when insert to database is success',
      () async {
        when(() => mockDatabaseHelper.insertTvWatchlist(testTvTable.toJson()))
            .thenAnswer((_) async => 1);
        final result = await dataSource.insertWatchlistTv(testTvTable);
        expect(result, 'Added to Watchlist');
      },
    );

    test(
      'should throw DatabaseException when insert to database is failed',
      () async {
        when(() => mockDatabaseHelper.insertTvWatchlist(testTvTable.toJson()))
            .thenThrow(Exception());
        final call = dataSource.insertWatchlistTv(testTvTable);
        expect(() => call, throwsA(isA<DatabaseException>()));
      },
    );
  });

  group('remove watchlist', () {
    test(
      'should return success message when remove from database is success',
      () async {
        when(() => mockDatabaseHelper.removeTvWatchlist(testTvTable.id))
            .thenAnswer((_) async => 1);
        final result = await dataSource.removeWatchlistTv(testTvTable);
        expect(result, 'Removed from Watchlist');
      },
    );

    test(
      'should throw DatabaseException when remove from database is failed',
      () async {
        when(() => mockDatabaseHelper.removeTvWatchlist(testTvTable.id))
            .thenThrow(Exception());
        final call = dataSource.removeWatchlistTv(testTvTable);
        expect(() => call, throwsA(isA<DatabaseException>()));
      },
    );
  });

  group('get tv by id', () {
    const tId = 1;

    test('should return TvTable when data is found', () async {
      when(() => mockDatabaseHelper.getTvById(tId))
          .thenAnswer((_) async => testTvMap);
      final result = await dataSource.getTvById(tId);
      expect(result, testTvTable);
    });

    test('should return null when data is not found', () async {
      when(() => mockDatabaseHelper.getTvById(tId))
          .thenAnswer((_) async => null);
      final result = await dataSource.getTvById(tId);
      expect(result, null);
    });
  });

  group('get watchlist tv', () {
    test('should return list of TvTable from database', () async {
      when(() => mockDatabaseHelper.getWatchlistTv())
          .thenAnswer((_) async => [testTvMap]);
      final result = await dataSource.getWatchlistTv();
      expect(result, [testTvTable]);
    });
  });

  group('TvTable', () {
    test('should convert to json and watchlist entity', () {
      expect(testTvTable.toJson(), testTvMap);
      expect(testTvTable.toEntity(), testWatchlistTv);
    });

    test('should be created from TvDetail entity', () {
      expect(
        TvTable.fromEntity(testTvDetail),
        const TvTable(
          id: 1,
          name: 'name',
          posterPath: 'posterPath',
          overview: 'overview',
        ),
      );
    });
  });
}
