import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';
import 'package:tv/presentation/bloc/search_tv_bloc.dart';
import 'package:tv/presentation/widgets/tv_card_list.dart';
import 'package:tv/presentation/widgets/tv_list.dart';

class SearchTvPage extends StatelessWidget {
  const SearchTvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search TV Series')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) =>
                  context.read<SearchTvBloc>().add(OnTvQueryChanged(query)),
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
              child: BlocBuilder<SearchTvBloc, TvListState>(
                builder: (context, state) => TvListStateView(
                  state: state,
                  emptyMessage: 'No TV series found',
                  builder: (tvs) => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tvs.length,
                    itemBuilder: (context, index) => TvCard(tvs[index]),
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
