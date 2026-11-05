import 'package:core/core.dart';
import 'package:ditonton/injection.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie/movie.dart';
import 'package:tv/tv.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => di.locator.reset());

  test('should wire every bloc with its dependencies', () async {
    final client = MockHttpClient();
    await di.init(client: client);

    expect(di.locator<http.Client>(), same(client));
    expect(di.locator<DatabaseHelper>(), isA<DatabaseHelper>());

    final blocs = [
      di.locator<NowPlayingMoviesBloc>(),
      di.locator<PopularMoviesBloc>(),
      di.locator<TopRatedMoviesBloc>(),
      di.locator<WatchlistMoviesBloc>(),
      di.locator<MovieDetailBloc>(),
      di.locator<MovieRecommendationsBloc>(),
      di.locator<SearchMoviesBloc>(),
      di.locator<MovieWatchlistBloc>(),
      di.locator<OnTheAirTvBloc>(),
      di.locator<PopularTvBloc>(),
      di.locator<TopRatedTvBloc>(),
      di.locator<WatchlistTvBloc>(),
      di.locator<TvDetailBloc>(),
      di.locator<TvRecommendationsBloc>(),
      di.locator<TvSeasonDetailBloc>(),
      di.locator<SearchTvBloc>(),
      di.locator<TvWatchlistBloc>(),
    ];
    expect(blocs, hasLength(17));
    for (final bloc in blocs) {
      await bloc.close();
    }
  });

  test('should use the SSL pinned client by default', () async {
    await di.init();

    expect(di.locator<http.Client>(), isA<IOClient>());
  });
}
