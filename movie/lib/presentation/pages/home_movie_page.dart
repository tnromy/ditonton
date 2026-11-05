import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';
import 'package:movie/presentation/widgets/movie_list.dart';

class HomeMoviePage extends StatefulWidget {
  const HomeMoviePage({super.key});

  @override
  State<HomeMoviePage> createState() => _HomeMoviePageState();
}

class _HomeMoviePageState extends State<HomeMoviePage> {
  @override
  void initState() {
    super.initState();
    context.read<NowPlayingMoviesBloc>().add(const FetchMovies());
    context.read<PopularMoviesBloc>().add(const FetchMovies());
    context.read<TopRatedMoviesBloc>().add(const FetchMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: homeMovieRoute),
      appBar: AppBar(
        title: const Text('Ditonton'),
        actions: [
          IconButton(
            tooltip: 'Search movies',
            onPressed: () => Navigator.pushNamed(context, searchMoviesRoute),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Now Playing', style: kHeading6),
              const _PosterSection<NowPlayingMoviesBloc>(),
              SubHeading(
                title: 'Popular',
                onTap: () => Navigator.pushNamed(context, popularMoviesRoute),
              ),
              const _PosterSection<PopularMoviesBloc>(),
              SubHeading(
                title: 'Top Rated',
                onTap: () => Navigator.pushNamed(context, topRatedMoviesRoute),
              ),
              const _PosterSection<TopRatedMoviesBloc>(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterSection<B extends StateStreamable<MovieListState>>
    extends StatelessWidget {
  const _PosterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, MovieListState>(
      builder: (context, state) =>
          MovieListStateView(state: state, builder: MoviePosterList.new),
    );
  }
}
