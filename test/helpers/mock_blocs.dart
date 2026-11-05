import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/injection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie/movie.dart';
import 'package:tv/tv.dart';

class MockNowPlayingMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements NowPlayingMoviesBloc {}

class MockPopularMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements PopularMoviesBloc {}

class MockTopRatedMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements TopRatedMoviesBloc {}

class MockWatchlistMoviesBloc extends MockBloc<MovieListEvent, MovieListState>
    implements WatchlistMoviesBloc {}

class MockMovieDetailBloc extends MockBloc<FetchMovieDetail, MovieDetailState>
    implements MovieDetailBloc {}

class MockMovieRecommendationsBloc
    extends MockBloc<FetchMovieRecommendations, MovieListState>
    implements MovieRecommendationsBloc {}

class MockMovieWatchlistBloc
    extends MockBloc<MovieWatchlistEvent, MovieWatchlistState>
    implements MovieWatchlistBloc {}

class MockSearchMoviesBloc extends MockBloc<OnMovieQueryChanged, MovieListState>
    implements SearchMoviesBloc {}

class MockOnTheAirTvBloc extends MockBloc<TvListEvent, TvListState>
    implements OnTheAirTvBloc {}

class MockPopularTvBloc extends MockBloc<TvListEvent, TvListState>
    implements PopularTvBloc {}

class MockTopRatedTvBloc extends MockBloc<TvListEvent, TvListState>
    implements TopRatedTvBloc {}

class MockWatchlistTvBloc extends MockBloc<TvListEvent, TvListState>
    implements WatchlistTvBloc {}

class MockTvDetailBloc extends MockBloc<FetchTvDetail, TvDetailState>
    implements TvDetailBloc {}

class MockTvRecommendationsBloc
    extends MockBloc<FetchTvRecommendations, TvListState>
    implements TvRecommendationsBloc {}

class MockTvWatchlistBloc extends MockBloc<TvWatchlistEvent, TvWatchlistState>
    implements TvWatchlistBloc {}

class MockTvSeasonDetailBloc
    extends MockBloc<FetchTvSeasonDetail, TvSeasonDetailState>
    implements TvSeasonDetailBloc {}

class MockSearchTvBloc extends MockBloc<OnTvQueryChanged, TvListState>
    implements SearchTvBloc {}

/// Holds one mock per bloc and registers them in the service locator so the
/// real [DitontonApp] can be pumped without network or database access.
class MockBlocs {
  final nowPlaying = MockNowPlayingMoviesBloc();
  final popularMovies = MockPopularMoviesBloc();
  final topRatedMovies = MockTopRatedMoviesBloc();
  final watchlistMovies = MockWatchlistMoviesBloc();
  final movieDetail = MockMovieDetailBloc();
  final movieRecommendations = MockMovieRecommendationsBloc();
  final movieWatchlist = MockMovieWatchlistBloc();
  final searchMovies = MockSearchMoviesBloc();
  final onTheAir = MockOnTheAirTvBloc();
  final popularTv = MockPopularTvBloc();
  final topRatedTv = MockTopRatedTvBloc();
  final watchlistTv = MockWatchlistTvBloc();
  final tvDetail = MockTvDetailBloc();
  final tvRecommendations = MockTvRecommendationsBloc();
  final tvWatchlist = MockTvWatchlistBloc();
  final tvSeason = MockTvSeasonDetailBloc();
  final searchTv = MockSearchTvBloc();

  static void registerFallbacks() {
    registerFallbackValue(const FetchMovies());
    registerFallbackValue(const FetchTv());
  }

  void stubInitialStates() {
    for (final bloc in [
      nowPlaying,
      popularMovies,
      topRatedMovies,
      watchlistMovies,
      movieRecommendations,
      searchMovies,
    ]) {
      when(() => bloc.state).thenReturn(const MovieListEmpty());
    }
    for (final bloc in [
      onTheAir,
      popularTv,
      topRatedTv,
      watchlistTv,
      tvRecommendations,
      searchTv,
    ]) {
      when(() => bloc.state).thenReturn(const TvListEmpty());
    }
    when(() => movieDetail.state).thenReturn(const MovieDetailEmpty());
    when(() => movieWatchlist.state).thenReturn(const MovieWatchlistState());
    when(() => tvDetail.state).thenReturn(const TvDetailEmpty());
    when(() => tvWatchlist.state).thenReturn(const TvWatchlistState());
    when(() => tvSeason.state).thenReturn(const TvSeasonDetailEmpty());
  }

  Future<void> register() async {
    await locator.reset();
    locator
      ..registerFactory<NowPlayingMoviesBloc>(() => nowPlaying)
      ..registerFactory<PopularMoviesBloc>(() => popularMovies)
      ..registerFactory<TopRatedMoviesBloc>(() => topRatedMovies)
      ..registerFactory<WatchlistMoviesBloc>(() => watchlistMovies)
      ..registerFactory<MovieDetailBloc>(() => movieDetail)
      ..registerFactory<MovieRecommendationsBloc>(() => movieRecommendations)
      ..registerFactory<MovieWatchlistBloc>(() => movieWatchlist)
      ..registerFactory<SearchMoviesBloc>(() => searchMovies)
      ..registerFactory<OnTheAirTvBloc>(() => onTheAir)
      ..registerFactory<PopularTvBloc>(() => popularTv)
      ..registerFactory<TopRatedTvBloc>(() => topRatedTv)
      ..registerFactory<WatchlistTvBloc>(() => watchlistTv)
      ..registerFactory<TvDetailBloc>(() => tvDetail)
      ..registerFactory<TvRecommendationsBloc>(() => tvRecommendations)
      ..registerFactory<TvWatchlistBloc>(() => tvWatchlist)
      ..registerFactory<TvSeasonDetailBloc>(() => tvSeason)
      ..registerFactory<SearchTvBloc>(() => searchTv);
  }
}
