import 'dart:convert';

import 'package:tv/data/models/episode_model.dart';
import 'package:tv/data/models/season_detail_model.dart';
import 'package:tv/data/models/season_model.dart';
import 'package:tv/data/models/tv_detail_model.dart';
import 'package:tv/domain/entities/episode.dart';
import 'package:tv/domain/entities/season.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../json_reader.dart';

void main() {
  group('SeasonModel', () {
    const tSeasonModel = SeasonModel(
      id: 3624,
      name: 'Season 1',
      seasonNumber: 1,
      episodeCount: 10,
      posterPath: '/poster.jpg',
      airDate: '2011-04-17',
    );

    test('should be a subclass of Season entity', () {
      expect(
        tSeasonModel.toEntity(),
        const Season(
          id: 3624,
          name: 'Season 1',
          seasonNumber: 1,
          episodeCount: 10,
          posterPath: '/poster.jpg',
          airDate: '2011-04-17',
        ),
      );
    });

    test('should survive a JSON round trip', () {
      expect(SeasonModel.fromJson(tSeasonModel.toJson()), tSeasonModel);
    });

    test('should default missing name and episode count', () {
      final result = SeasonModel.fromJson({'id': 1, 'season_number': 0});
      expect(result.name, '');
      expect(result.episodeCount, 0);
    });
  });

  group('EpisodeModel', () {
    const tEpisodeModel = EpisodeModel(
      id: 63056,
      name: 'Winter Is Coming',
      episodeNumber: 1,
      overview: 'overview',
      stillPath: '/still.jpg',
      airDate: '2011-04-17',
      runtime: 62,
      voteAverage: 8.2,
    );

    test('should be a subclass of Episode entity', () {
      expect(
        tEpisodeModel.toEntity(),
        const Episode(
          id: 63056,
          name: 'Winter Is Coming',
          episodeNumber: 1,
          overview: 'overview',
          stillPath: '/still.jpg',
          airDate: '2011-04-17',
          runtime: 62,
          voteAverage: 8.2,
        ),
      );
    });

    test('should survive a JSON round trip', () {
      expect(EpisodeModel.fromJson(tEpisodeModel.toJson()), tEpisodeModel);
    });

    test('should parse integer vote average as double', () {
      final result = EpisodeModel.fromJson({
        'id': 1,
        'episode_number': 1,
        'vote_average': 8,
      });
      expect(result.voteAverage, 8.0);
      expect(result.overview, '');
    });
  });

  group('SeasonDetailResponse', () {
    test('should parse season detail from TMDB JSON', () {
      final jsonMap = json.decode(readJson('dummy_data/season_detail.json'));
      final result = SeasonDetailResponse.fromJson(jsonMap);

      expect(result.id, 3624);
      expect(result.seasonNumber, 1);
      expect(result.episodes.length, 2);
      expect(result.episodes.first.name, 'Winter Is Coming');
      expect(result.episodes.first.runtime, 62);
    });

    test('should convert to SeasonDetail entity with episodes', () {
      final jsonMap = json.decode(readJson('dummy_data/season_detail.json'));
      final entity = SeasonDetailResponse.fromJson(jsonMap).toEntity();

      expect(entity.name, 'Season 1');
      expect(entity.episodes.length, 2);
      expect(entity.episodes[1].episodeNumber, 2);
    });

    test('should survive a JSON round trip', () {
      final jsonMap = json.decode(readJson('dummy_data/season_detail.json'));
      final model = SeasonDetailResponse.fromJson(jsonMap);
      expect(SeasonDetailResponse.fromJson(model.toJson()), model);
    });
  });

  group('TvDetailResponse seasons', () {
    test('should parse seasons from TV detail JSON', () {
      final jsonMap = json.decode(readJson('dummy_data/tv_detail.json'));
      final result = TvDetailResponse.fromJson(jsonMap);

      expect(result.seasons.length, 1);
      expect(result.toEntity().seasons.first.name, 'Season 1');
      expect(TvDetailResponse.fromJson(result.toJson()), result);
    });

    test('should return empty seasons when field is missing', () {
      final jsonMap = json.decode(readJson('dummy_data/tv_detail.json')) as Map;
      jsonMap.remove('seasons');
      final result = TvDetailResponse.fromJson(
        Map<String, dynamic>.from(jsonMap),
      );
      expect(result.seasons, isEmpty);
    });
  });
}
