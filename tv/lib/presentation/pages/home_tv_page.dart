import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';
import 'package:tv/presentation/widgets/tv_list.dart';

class HomeTvPage extends StatefulWidget {
  const HomeTvPage({super.key});

  @override
  State<HomeTvPage> createState() => _HomeTvPageState();
}

class _HomeTvPageState extends State<HomeTvPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnTheAirTvBloc>().add(const FetchTv());
    context.read<PopularTvBloc>().add(const FetchTv());
    context.read<TopRatedTvBloc>().add(const FetchTv());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: homeTvRoute),
      appBar: AppBar(
        title: const Text('Ditonton'),
        actions: [
          IconButton(
            tooltip: 'Search TV series',
            onPressed: () => Navigator.pushNamed(context, searchTvRoute),
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
              SubHeading(
                title: 'On The Air',
                onTap: () => Navigator.pushNamed(context, onTheAirTvRoute),
              ),
              const _PosterSection<OnTheAirTvBloc>(),
              SubHeading(
                title: 'Popular',
                onTap: () => Navigator.pushNamed(context, popularTvRoute),
              ),
              const _PosterSection<PopularTvBloc>(),
              SubHeading(
                title: 'Top Rated',
                onTap: () => Navigator.pushNamed(context, topRatedTvRoute),
              ),
              const _PosterSection<TopRatedTvBloc>(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterSection<B extends StateStreamable<TvListState>>
    extends StatelessWidget {
  const _PosterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, TvListState>(
      builder: (context, state) =>
          TvListStateView(state: state, builder: TvPosterList.new),
    );
  }
}
