import 'package:tv/domain/entities/episode.dart';
import 'package:equatable/equatable.dart';

class SeasonDetail extends Equatable {
  const SeasonDetail({
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
  final List<Episode> episodes;

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
