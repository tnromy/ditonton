import 'package:tv/domain/entities/season.dart';
import 'package:equatable/equatable.dart';

class SeasonModel extends Equatable {
  const SeasonModel({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
    required this.posterPath,
    required this.airDate,
  });

  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;
  final String? posterPath;
  final String? airDate;

  factory SeasonModel.fromJson(Map<String, dynamic> json) => SeasonModel(
    id: json["id"],
    name: json["name"] ?? '',
    seasonNumber: json["season_number"],
    episodeCount: json["episode_count"] ?? 0,
    posterPath: json["poster_path"],
    airDate: json["air_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "season_number": seasonNumber,
    "episode_count": episodeCount,
    "poster_path": posterPath,
    "air_date": airDate,
  };

  Season toEntity() => Season(
    id: id,
    name: name,
    seasonNumber: seasonNumber,
    episodeCount: episodeCount,
    posterPath: posterPath,
    airDate: airDate,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    seasonNumber,
    episodeCount,
    posterPath,
    airDate,
  ];
}
