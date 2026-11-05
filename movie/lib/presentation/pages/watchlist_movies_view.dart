import 'package:flutter/material.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';
import 'package:movie/presentation/widgets/movie_list.dart';

/// Watchlist content for movies, embedded as a tab in the app watchlist page.
class WatchlistMoviesView extends StatelessWidget {
  const WatchlistMoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MovieCardListView<WatchlistMoviesBloc>(
      emptyMessage: 'No movie in your watchlist yet',
    );
  }
}
