import 'package:core/core.dart';
import 'package:tv/data/models/tv_table.dart';
import 'package:tv/domain/entities/episode.dart';
import 'package:tv/domain/entities/season.dart';
import 'package:tv/domain/entities/season_detail.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/domain/entities/tv_detail.dart';

final testTv = Tv(
  backdropPath: '/muth4OYamXf41G2evdrLEg8d3om.jpg',
  genreIds: [10765, 10759],
  id: 1399,
  originalName: 'Game of Thrones',
  overview: 'Seven noble families fight for control of the mythical land of Westeros.',
  popularity: 369.594,
  posterPath: '/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
  firstAirDate: '2011-04-17',
  name: 'Game of Thrones',
  voteAverage: 8.3,
  voteCount: 11504,
);

final testTvList = [testTv];

const testSeason = Season(
  id: 3624,
  name: 'Season 1',
  seasonNumber: 1,
  episodeCount: 10,
  posterPath: '/season1.jpg',
  airDate: '2011-04-17',
);

const testEpisode = Episode(
  id: 63056,
  name: 'Winter Is Coming',
  episodeNumber: 1,
  overview: 'overview',
  stillPath: '/still.jpg',
  airDate: '2011-04-17',
  runtime: 62,
  voteAverage: 8.2,
);

const testSeasonDetail = SeasonDetail(
  id: 3624,
  name: 'Season 1',
  seasonNumber: 1,
  overview: 'season overview',
  posterPath: '/season1.jpg',
  airDate: '2011-04-17',
  episodes: [testEpisode],
);

final testTvDetail = TvDetail(
  backdropPath: 'backdropPath',
  genres: [Genre(id: 1, name: 'Action')],
  id: 1,
  originalName: 'originalName',
  overview: 'overview',
  posterPath: 'posterPath',
  firstAirDate: 'firstAirDate',
  name: 'name',
  numberOfEpisodes: 10,
  numberOfSeasons: 1,
  seasons: [testSeason],
  voteAverage: 1,
  voteCount: 1,
);

final testWatchlistTv = Tv.watchlist(
  id: 1,
  name: 'name',
  posterPath: 'posterPath',
  overview: 'overview',
);

final testTvTable = TvTable(
  id: 1,
  name: 'name',
  posterPath: 'posterPath',
  overview: 'overview',
);

final testTvMap = {
  'id': 1,
  'overview': 'overview',
  'posterPath': 'posterPath',
  'name': 'name',
};
