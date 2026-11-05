import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';

/// Horizontal list of posters that opens the movie detail on tap.
class MoviePosterList extends StatelessWidget {
  const MoviePosterList(
    this.movies, {
    super.key,
    this.height = 200,
    this.replaceRoute = false,
  });

  final List<Movie> movies;
  final double height;
  final bool replaceRoute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              key: Key('movie_poster_${movie.id}'),
              onTap: () => replaceRoute
                  ? Navigator.pushReplacementNamed(
                      context,
                      movieDetailRoute,
                      arguments: movie.id,
                    )
                  : Navigator.pushNamed(
                      context,
                      movieDetailRoute,
                      arguments: movie.id,
                    ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: '$baseImageUrl${movie.posterPath}',
                  placeholder: networkImagePlaceholder,
                  errorWidget: networkImageError,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Renders any [MovieListState] with a custom widget for the loaded data.
class MovieListStateView extends StatelessWidget {
  const MovieListStateView({
    super.key,
    required this.state,
    required this.builder,
    this.emptyMessage,
  });

  final MovieListState state;
  final Widget Function(List<Movie> movies) builder;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is MovieListLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (current is MovieListError) {
      return Center(
        key: const Key('error_message'),
        child: Text(current.message),
      );
    }
    if (current is MovieListHasData) {
      if (current.movies.isEmpty && emptyMessage != null) {
        return Center(
          key: const Key('empty_message'),
          child: Text(emptyMessage!),
        );
      }
      return builder(current.movies);
    }
    return const SizedBox.shrink();
  }
}

/// Vertical list of [MovieCard] driven by a [MovieListBloc] of type [B].
class MovieCardListView<B extends StateStreamable<MovieListState>>
    extends StatelessWidget {
  const MovieCardListView({super.key, this.emptyMessage});

  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, MovieListState>(
      builder: (context, state) => MovieListStateView(
        state: state,
        emptyMessage: emptyMessage,
        builder: (movies) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: movies.length,
          itemBuilder: (context, index) => MovieCard(movies[index]),
        ),
      ),
    );
  }
}
