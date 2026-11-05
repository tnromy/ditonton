import 'package:equatable/equatable.dart';

class Episode extends Equatable {
  const Episode({
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
