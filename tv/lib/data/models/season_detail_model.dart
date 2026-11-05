import 'package:tv/data/models/episode_model.dart';
import 'package:tv/domain/entities/season_detail.dart';
import 'package:equatable/equatable.dart';

class SeasonDetailResponse extends Equatable {
  const SeasonDetailResponse({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.overview,
    required this.posterPath,
    required this.airDate,
    required this.episodes,
  });

  final int id;
  final String name;
  final int seasonNumber;
  final String overview;
  final String? posterPath;
  final String? airDate;
  final List<EpisodeModel> episodes;

  factory SeasonDetailResponse.fromJson(Map<String, dynamic> json) =>
      SeasonDetailResponse(
        id: json["id"],
        name: json["name"] ?? '',
        seasonNumber: json["season_number"],
        overview: json["overview"] ?? '',
        posterPath: json["poster_path"],
        airDate: json["air_date"],
        episodes: List<EpisodeModel>.from(
          (json["episodes"] ?? []).map((x) => EpisodeModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "season_number": seasonNumber,
    "overview": overview,
    "poster_path": posterPath,
    "air_date": airDate,
    "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
  };

  SeasonDetail toEntity() => SeasonDetail(
    id: id,
    name: name,
    seasonNumber: seasonNumber,
    overview: overview,
    posterPath: posterPath,
    airDate: airDate,
    episodes: episodes.map((episode) => episode.toEntity()).toList(),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    seasonNumber,
    overview,
    posterPath,
    airDate,
    episodes,
  ];
}
