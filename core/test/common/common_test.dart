import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenreModel', () {
    const model = GenreModel(id: 1, name: 'Action');

    test('should map to the Genre entity', () {
      expect(model.toEntity(), const Genre(id: 1, name: 'Action'));
    });

    test('should survive a JSON round trip', () {
      expect(model.toJson(), {'id': 1, 'name': 'Action'});
      expect(GenreModel.fromJson(model.toJson()), model);
    });
  });

  test('failures should compare by message', () {
    expect(const ServerFailure('a'), const ServerFailure('a'));
    expect(const ConnectionFailure('b').props, ['b']);
    expect(const DatabaseFailure('c').message, 'c');
  });

  test('DatabaseException should keep its message', () {
    expect(DatabaseException('boom').message, 'boom');
    expect(ServerException(), isA<Exception>());
  });

  test('theme constants should use the Ditonton palette', () {
    expect(kColorScheme.primary, kMikadoYellow);
    expect(kTextTheme.headlineSmall, kHeading6);
    expect(kDrawerTheme.backgroundColor, isNotNull);
    expect(baseImageUrl, startsWith('https://image.tmdb.org'));
    expect(kSubtitle.fontSize, 15);
    expect(kBodyText.fontSize, 13);
    expect(kHeading5.fontSize, 23);
    expect(routeObserver, isA<RouteObserver<ModalRoute>>());
  });
}
