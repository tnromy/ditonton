import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tv/tv.dart';

class MockTvRepository extends Mock implements TvRepository {}

class MockTvRemoteDataSource extends Mock implements TvRemoteDataSource {}

class MockTvLocalDataSource extends Mock implements TvLocalDataSource {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockHttpClient extends Mock implements http.Client {}

class MockGetOnTheAirTv extends Mock implements GetOnTheAirTv {}

class MockGetPopularTv extends Mock implements GetPopularTv {}

class MockGetTopRatedTv extends Mock implements GetTopRatedTv {}

class MockGetWatchlistTv extends Mock implements GetWatchlistTv {}

class MockGetTvDetail extends Mock implements GetTvDetail {}

class MockGetTvRecommendations extends Mock implements GetTvRecommendations {}

class MockGetTvSeasonDetail extends Mock implements GetTvSeasonDetail {}

class MockSearchTv extends Mock implements SearchTv {}

class MockGetWatchlistStatusTv extends Mock implements GetWatchlistStatusTv {}

class MockSaveWatchlistTv extends Mock implements SaveWatchlistTv {}

class MockRemoveWatchlistTv extends Mock implements RemoveWatchlistTv {}
