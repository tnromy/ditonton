import 'package:ditonton/app.dart';
import 'package:ditonton/injection.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie/movie.dart';
import 'package:tv/tv.dart';

/// End-to-end flows against the real TMDB API (through the SSL pinned client)
/// and the real SQLite database. Run with:
/// `flutter test integration_test -d <device>`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.init();
  });

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  Future<void> pumpFor(WidgetTester tester, [int millis = 1500]) async {
    final end = DateTime.now().add(Duration(milliseconds: millis));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Finder keyStartsWith(String prefix) => find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith(prefix),
  );

  Future<void> openDrawerItem(WidgetTester tester, String item) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await pumpFor(tester, 800);
    await tester.tap(find.text(item));
    await pumpFor(tester);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.pageBack();
    await pumpFor(tester);
  }

  Future<void> tapWatchlistButton(WidgetTester tester, String message) async {
    await tester.tap(find.byType(FilledButton));
    await pumpUntilFound(tester, find.text(message));
    await pumpFor(tester, 4500);
  }

  testWidgets('movie: open detail, add to watchlist, see it, then remove', (
    tester,
  ) async {
    await tester.pumpWidget(const DitontonApp());
    await pumpUntilFound(tester, keyStartsWith('movie_poster_'));

    await tester.tap(keyStartsWith('movie_poster_').first);
    await pumpUntilFound(tester, find.byType(MovieDetailContent));
    expect(find.text('Overview'), findsOneWidget);

    await tapWatchlistButton(tester, MovieWatchlistBloc.addSuccessMessage);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFor(tester);
    await openDrawerItem(tester, 'Watchlist');
    await pumpUntilFound(tester, find.byType(MovieCard));

    await tester.tap(find.byType(MovieCard).first);
    await pumpUntilFound(tester, find.byIcon(Icons.check));
    await tapWatchlistButton(tester, MovieWatchlistBloc.removeSuccessMessage);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpUntilFound(tester, find.text('No movie in your watchlist yet'));
  });

  testWidgets('tv: On The Air page, detail with seasons and episodes', (
    tester,
  ) async {
    await tester.pumpWidget(const DitontonApp());
    await pumpFor(tester);
    await openDrawerItem(tester, 'TV Series');
    await pumpUntilFound(tester, keyStartsWith('tv_poster_'));

    await tester.tap(find.text('See More').first);
    await pumpUntilFound(tester, find.byType(TvCard));
    expect(find.text('On The Air TV Series'), findsOneWidget);
    await back(tester);

    await tester.tap(keyStartsWith('tv_poster_').first);
    await pumpUntilFound(tester, find.byType(SeasonList));
    final season = keyStartsWith('season_');
    if (season.evaluate().isNotEmpty) {
      await tester.ensureVisible(season.first);
      await pumpFor(tester, 500);
      await tester.tap(season.first);
      await pumpUntilFound(tester, find.byType(EpisodeCard));
      expect(find.textContaining('Episode 1:'), findsWidgets);
    }
  });

  testWidgets('search: movies and TV series by title', (tester) async {
    await tester.pumpWidget(const DitontonApp());
    await pumpFor(tester);

    await tester.tap(find.byTooltip('Search movies'));
    await pumpFor(tester);
    await tester.enterText(find.byType(TextField), 'Spider-Man');
    await pumpUntilFound(tester, find.byType(MovieCard));
    await back(tester);

    await openDrawerItem(tester, 'TV Series');
    await tester.tap(find.byTooltip('Search TV series'));
    await pumpFor(tester);
    await tester.enterText(find.byType(TextField), 'Game of Thrones');
    await pumpUntilFound(tester, find.byType(TvCard));
  });
}
