import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:movie/movie.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockHttpClient extends Mock implements http.Client {}

class MockGetNowPlayingMovies extends Mock implements GetNowPlayingMovies {}

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

class MockGetTopRatedMovies extends Mock implements GetTopRatedMovies {}

class MockGetWatchlistMovies extends Mock implements GetWatchlistMovies {}

class MockGetMovieDetail extends Mock implements GetMovieDetail {}

class MockGetMovieRecommendations extends Mock
    implements GetMovieRecommendations {}

class MockSearchMovies extends Mock implements SearchMovies {}

class MockGetWatchListStatus extends Mock implements GetWatchListStatus {}

class MockSaveWatchlist extends Mock implements SaveWatchlist {}

class MockRemoveWatchlist extends Mock implements RemoveWatchlist {}
