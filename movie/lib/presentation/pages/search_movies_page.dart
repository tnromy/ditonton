import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';
import 'package:movie/presentation/bloc/search_movies_bloc.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';
import 'package:movie/presentation/widgets/movie_list.dart';

class SearchMoviesPage extends StatelessWidget {
  const SearchMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Movies')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) => context.read<SearchMoviesBloc>().add(
                OnMovieQueryChanged(query),
              ),
              decoration: const InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            Text('Search Result', style: kHeading6),
            Expanded(
              child: BlocBuilder<SearchMoviesBloc, MovieListState>(
                builder: (context, state) => MovieListStateView(
                  state: state,
                  emptyMessage: 'No movie found',
                  builder: (movies) => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: movies.length,
                    itemBuilder: (context, index) => MovieCard(movies[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
