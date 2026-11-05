import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:movie/presentation/bloc/movie_detail_bloc.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';
import 'package:movie/presentation/bloc/movie_recommendations_bloc.dart';
import 'package:movie/presentation/bloc/movie_watchlist_bloc.dart';
import 'package:movie/presentation/widgets/movie_list.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.id});

  final int id;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailBloc>().add(FetchMovieDetail(widget.id));
    context.read<MovieRecommendationsBloc>().add(
      FetchMovieRecommendations(widget.id),
    );
    context.read<MovieWatchlistBloc>().add(LoadMovieWatchlistStatus(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailHasData) {
            return SafeArea(child: MovieDetailContent(state.movie));
          }
          if (state is MovieDetailError) {
            return Center(
              key: const Key('error_message'),
              child: Text(state.message),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MovieDetailContent extends StatelessWidget {
  const MovieDetailContent(this.movie, {super.key});

  final MovieDetail movie;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: '$baseImageUrl${movie.posterPath}',
          width: screenWidth,
          placeholder: networkImagePlaceholder,
          errorWidget: networkImageError,
        ),
        Container(
          margin: const EdgeInsets.only(top: 48 + 8),
          child: DraggableScrollableSheet(
            minChildSize: 0.25,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: kRichBlack,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.title, style: kHeading5),
                            MovieWatchlistButton(movie),
                            Text(showGenres(movie)),
                            Text(showDuration(movie.runtime)),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: movie.voteAverage / 2,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: kMikadoYellow,
                                  ),
                                  itemSize: 24,
                                ),
                                Text('${movie.voteAverage}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Overview', style: kHeading6),
                            Text(movie.overview),
                            const SizedBox(height: 16),
                            Text('Recommendations', style: kHeading6),
                            BlocBuilder<
                              MovieRecommendationsBloc,
                              MovieListState
                            >(
                              builder: (context, state) => MovieListStateView(
                                state: state,
                                emptyMessage: 'No recommendations',
                                builder: (movies) => MoviePosterList(
                                  movies,
                                  height: 150,
                                  replaceRoute: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        color: Colors.white,
                        height: 4,
                        width: 48,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kRichBlack,
            foregroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  static String showGenres(MovieDetail movie) =>
      movie.genres.map((genre) => genre.name).join(', ');

  static String showDuration(int runtime) {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

class MovieWatchlistButton extends StatelessWidget {
  const MovieWatchlistButton(this.movie, {super.key});

  final MovieDetail movie;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MovieWatchlistBloc, MovieWatchlistState>(
      listenWhen: (previous, current) =>
          current.message.isNotEmpty && previous.message != current.message,
      listener: (context, state) {
        if (state.message == MovieWatchlistBloc.addSuccessMessage ||
            state.message == MovieWatchlistBloc.removeSuccessMessage) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) => FilledButton(
        onPressed: () {
          final bloc = context.read<MovieWatchlistBloc>();
          bloc.add(
            state.isAdded
                ? RemoveMovieFromWatchlist(movie)
                : AddMovieToWatchlist(movie),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(state.isAdded ? Icons.check : Icons.add),
            const Text('Watchlist'),
          ],
        ),
      ),
    );
  }
}
