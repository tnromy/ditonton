import 'package:equatable/equatable.dart';

class Season extends Equatable {
  const Season({
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
