import 'package:flutter/material.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';
import 'package:tv/presentation/widgets/tv_list.dart';

/// Watchlist content for tvs, embedded as a tab in the app watchlist page.
class WatchlistTvView extends StatelessWidget {
  const WatchlistTvView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TvCardListView<WatchlistTvBloc>(
      emptyMessage: 'No TV series in your watchlist yet',
    );
  }
}
