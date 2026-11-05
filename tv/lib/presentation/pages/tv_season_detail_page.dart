import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/entities/episode.dart';
import 'package:tv/domain/entities/season_detail.dart';
import 'package:tv/presentation/bloc/tv_season_detail_bloc.dart';

class TvSeasonDetailArguments {
  const TvSeasonDetailArguments({
    required this.tvId,
    required this.seasonNumber,
    required this.seasonName,
  });

  final int tvId;
  final int seasonNumber;
  final String seasonName;
}

class TvSeasonDetailPage extends StatefulWidget {
  const TvSeasonDetailPage({super.key, required this.args});

  final TvSeasonDetailArguments args;

  @override
  State<TvSeasonDetailPage> createState() => _TvSeasonDetailPageState();
}

class _TvSeasonDetailPageState extends State<TvSeasonDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TvSeasonDetailBloc>().add(
      FetchTvSeasonDetail(
        tvId: widget.args.tvId,
        seasonNumber: widget.args.seasonNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.args.seasonName)),
      body: BlocBuilder<TvSeasonDetailBloc, TvSeasonDetailState>(
        builder: (context, state) {
          if (state is TvSeasonDetailHasData) {
            return _SeasonContent(state.season);
          }
          if (state is TvSeasonDetailError) {
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

class _SeasonContent extends StatelessWidget {
  const _SeasonContent(this.season);

  final SeasonDetail season;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: season.episodes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader();
        return EpisodeCard(season.episodes[index - 1]);
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${season.episodes.length} Episode(s)'
            '${season.airDate != null ? ' • ${season.airDate}' : ''}',
            style: kSubtitle,
          ),
          if (season.overview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(season.overview),
          ],
        ],
      ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  const EpisodeCard(this.episode, {super.key});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final info = [
      if (episode.airDate != null) episode.airDate!,
      if (episode.runtime != null) '${episode.runtime} min',
      '★ ${episode.voteAverage.toStringAsFixed(1)}',
    ].join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.stillPath != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: '$baseImageUrl${episode.stillPath}',
                fit: BoxFit.cover,
                placeholder: networkImagePlaceholder,
                errorWidget: networkImageError,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Episode ${episode.episodeNumber}: ${episode.name}',
                  style: kHeading6,
                ),
                const SizedBox(height: 4),
                Text(info, style: kBodyText),
                if (episode.overview.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(episode.overview),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
