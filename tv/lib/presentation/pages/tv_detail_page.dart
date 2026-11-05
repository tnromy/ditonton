import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tv/domain/entities/season.dart';
import 'package:tv/domain/entities/tv_detail.dart';
import 'package:tv/presentation/bloc/tv_detail_bloc.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';
import 'package:tv/presentation/bloc/tv_recommendations_bloc.dart';
import 'package:tv/presentation/bloc/tv_watchlist_bloc.dart';
import 'package:tv/presentation/pages/tv_season_detail_page.dart';
import 'package:tv/presentation/widgets/tv_list.dart';

class TvDetailPage extends StatefulWidget {
  const TvDetailPage({super.key, required this.id});

  final int id;

  @override
  State<TvDetailPage> createState() => _TvDetailPageState();
}

class _TvDetailPageState extends State<TvDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TvDetailBloc>().add(FetchTvDetail(widget.id));
    context.read<TvRecommendationsBloc>().add(
      FetchTvRecommendations(widget.id),
    );
    context.read<TvWatchlistBloc>().add(LoadTvWatchlistStatus(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TvDetailBloc, TvDetailState>(
        builder: (context, state) {
          if (state is TvDetailHasData) {
            return SafeArea(child: TvDetailContent(state.tv));
          }
          if (state is TvDetailError) {
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

class TvDetailContent extends StatelessWidget {
  const TvDetailContent(this.tv, {super.key});

  final TvDetail tv;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: '$baseImageUrl${tv.posterPath}',
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
                            Text(tv.name, style: kHeading5),
                            TvWatchlistButton(tv),
                            Text(
                              tv.genres.map((genre) => genre.name).join(', '),
                            ),
                            Text(
                              '${tv.numberOfSeasons} Season(s), '
                              '${tv.numberOfEpisodes} Episode(s)',
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: tv.voteAverage / 2,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: kMikadoYellow,
                                  ),
                                  itemSize: 24,
                                ),
                                Text('${tv.voteAverage}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Overview', style: kHeading6),
                            Text(tv.overview),
                            const SizedBox(height: 16),
                            Text('Seasons', style: kHeading6),
                            SeasonList(tvId: tv.id, seasons: tv.seasons),
                            const SizedBox(height: 16),
                            Text('Recommendations', style: kHeading6),
                            BlocBuilder<TvRecommendationsBloc, TvListState>(
                              builder: (context, state) => TvListStateView(
                                state: state,
                                emptyMessage: 'No recommendations',
                                builder: (tvs) => TvPosterList(
                                  tvs,
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
}

class SeasonList extends StatelessWidget {
  const SeasonList({super.key, required this.tvId, required this.seasons});

  final int tvId;
  final List<Season> seasons;

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) {
      return const Text('No season information');
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final season = seasons[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: InkWell(
              key: Key('season_${season.seasonNumber}'),
              onTap: () => Navigator.pushNamed(
                context,
                tvSeasonDetailRoute,
                arguments: TvSeasonDetailArguments(
                  tvId: tvId,
                  seasonNumber: season.seasonNumber,
                  seasonName: season.name,
                ),
              ),
              child: SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        child: season.posterPath != null
                            ? CachedNetworkImage(
                                imageUrl: '$baseImageUrl${season.posterPath}',
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: networkImagePlaceholder,
                                errorWidget: networkImageError,
                              )
                            : Container(
                                width: 100,
                                color: kDavysGrey,
                                child: const Icon(Icons.tv),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      season.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('${season.episodeCount} Episode(s)', style: kBodyText),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TvWatchlistButton extends StatelessWidget {
  const TvWatchlistButton(this.tv, {super.key});

  final TvDetail tv;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TvWatchlistBloc, TvWatchlistState>(
      listenWhen: (previous, current) =>
          current.message.isNotEmpty && previous.message != current.message,
      listener: (context, state) {
        if (state.message == TvWatchlistBloc.addSuccessMessage ||
            state.message == TvWatchlistBloc.removeSuccessMessage) {
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
        onPressed: () => context.read<TvWatchlistBloc>().add(
          state.isAdded ? RemoveTvFromWatchlist(tv) : AddTvToWatchlist(tv),
        ),
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
