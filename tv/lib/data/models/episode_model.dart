import 'package:tv/domain/entities/episode.dart';
import 'package:equatable/equatable.dart';

class EpisodeModel extends Equatable {
  const EpisodeModel({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.overview,
    required this.stillPath,
    required this.airDate,
    required this.runtime,
    required this.voteAverage,
  });

  final int id;
  final String name;
  final int episodeNumber;
  final String overview;
  final String? stillPath;
  final String? airDate;
  final int? runtime;
  final double voteAverage;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
    id: json["id"],
    name: json["name"] ?? '',
    episodeNumber: json["episode_number"],
    overview: json["overview"] ?? '',
    stillPath: json["still_path"],
    airDate: json["air_date"],
    runtime: json["runtime"],
    voteAverage: (json["vote_average"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "episode_number": episodeNumber,
    "overview": overview,
    "still_path": stillPath,
    "air_date": airDate,
    "runtime": runtime,
    "vote_average": voteAverage,
  };

  Episode toEntity() => Episode(
    id: id,
    name: name,
    episodeNumber: episodeNumber,
    overview: overview,
    stillPath: stillPath,
    airDate: airDate,
    runtime: runtime,
    voteAverage: voteAverage,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    episodeNumber,
    overview,
    stillPath,
    airDate,
    runtime,
    voteAverage,
  ];
}
