import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie/data/models/movie_detail_model.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';

import '../../json_reader.dart';

void main() {
  final jsonMap = json.decode(
    readJson('dummy_data/movie_detail.json'),
  ) as Map<String, dynamic>;

  test('should parse movie detail from TMDB JSON', () {
    final result = MovieDetailResponse.fromJson(jsonMap);

    expect(result.id, jsonMap['id']);
    expect(result.title, jsonMap['title']);
    expect(result.genres, isNotEmpty);
  });

  test('should map to the MovieDetail entity', () {
    final entity = MovieDetailResponse.fromJson(jsonMap).toEntity();

    expect(entity.id, jsonMap['id']);
    expect(entity.runtime, jsonMap['runtime']);
    expect(entity.genres.first.name, jsonMap['genres'][0]['name']);
  });

  test('should survive a JSON round trip', () {
    final model = MovieDetailResponse.fromJson(jsonMap);
    expect(MovieDetailResponse.fromJson(model.toJson()), model);
  });

  test('FetchMovies should have no props', () {
    expect(FetchMovies().props, isEmpty);
    expect(MovieListEmpty().props, isEmpty);
  });
}
