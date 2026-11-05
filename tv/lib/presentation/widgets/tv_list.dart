import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';
import 'package:tv/presentation/widgets/tv_card_list.dart';

/// Horizontal list of posters that opens the TV series detail on tap.
class TvPosterList extends StatelessWidget {
  const TvPosterList(
    this.tvs, {
    super.key,
    this.height = 200,
    this.replaceRoute = false,
  });

  final List<Tv> tvs;
  final double height;
  final bool replaceRoute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tvs.length,
        itemBuilder: (context, index) {
          final tv = tvs[index];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              key: Key('tv_poster_${tv.id}'),
              onTap: () => replaceRoute
                  ? Navigator.pushReplacementNamed(
                      context,
                      tvDetailRoute,
                      arguments: tv.id,
                    )
                  : Navigator.pushNamed(
                      context,
                      tvDetailRoute,
                      arguments: tv.id,
                    ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: '$baseImageUrl${tv.posterPath}',
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

/// Renders any [TvListState] with a custom widget for the loaded data.
class TvListStateView extends StatelessWidget {
  const TvListStateView({
    super.key,
    required this.state,
    required this.builder,
    this.emptyMessage,
  });

  final TvListState state;
  final Widget Function(List<Tv> tvs) builder;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is TvListLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (current is TvListError) {
      return Center(
        key: const Key('error_message'),
        child: Text(current.message),
      );
    }
    if (current is TvListHasData) {
      if (current.tvs.isEmpty && emptyMessage != null) {
        return Center(
          key: const Key('empty_message'),
          child: Text(emptyMessage!),
        );
      }
      return builder(current.tvs);
    }
    return const SizedBox.shrink();
  }
}

/// Vertical list of [TvCard] driven by a [TvListBloc] of type [B].
class TvCardListView<B extends StateStreamable<TvListState>>
    extends StatelessWidget {
  const TvCardListView({super.key, this.emptyMessage});

  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, TvListState>(
      builder: (context, state) => TvListStateView(
        state: state,
        emptyMessage: emptyMessage,
        builder: (tvs) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: tvs.length,
          itemBuilder: (context, index) => TvCard(tvs[index]),
        ),
      ),
    );
  }
}
