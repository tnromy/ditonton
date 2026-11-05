import 'package:about/about.dart';
import 'package:core/core.dart';
import 'package:ditonton/injection.dart';
import 'package:ditonton/presentation/pages/watchlist_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/movie.dart';
import 'package:tv/tv.dart';

class DitontonApp extends StatelessWidget {
  const DitontonApp({super.key, this.navigatorObservers = const []});

  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator<NowPlayingMoviesBloc>()),
        BlocProvider(create: (_) => locator<PopularMoviesBloc>()),
        BlocProvider(create: (_) => locator<TopRatedMoviesBloc>()),
        BlocProvider(create: (_) => locator<WatchlistMoviesBloc>()),
        BlocProvider(create: (_) => locator<MovieDetailBloc>()),
        BlocProvider(create: (_) => locator<MovieRecommendationsBloc>()),
        BlocProvider(create: (_) => locator<MovieWatchlistBloc>()),
        BlocProvider(create: (_) => locator<SearchMoviesBloc>()),
        BlocProvider(create: (_) => locator<OnTheAirTvBloc>()),
        BlocProvider(create: (_) => locator<PopularTvBloc>()),
        BlocProvider(create: (_) => locator<TopRatedTvBloc>()),
        BlocProvider(create: (_) => locator<WatchlistTvBloc>()),
        BlocProvider(create: (_) => locator<TvDetailBloc>()),
        BlocProvider(create: (_) => locator<TvRecommendationsBloc>()),
        BlocProvider(create: (_) => locator<TvWatchlistBloc>()),
        BlocProvider(create: (_) => locator<TvSeasonDetailBloc>()),
        BlocProvider(create: (_) => locator<SearchTvBloc>()),
      ],
      child: MaterialApp(
        title: 'Ditonton',
        theme: ThemeData.dark().copyWith(
          colorScheme: kColorScheme,
          primaryColor: kRichBlack,
          scaffoldBackgroundColor: kRichBlack,
          textTheme: kTextTheme,
          drawerTheme: kDrawerTheme,
        ),
        home: const HomeMoviePage(),
        navigatorObservers: [routeObserver, ...navigatorObservers],
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  Widget page;
  var cupertino = false;
  switch (settings.name) {
    case homeMovieRoute:
      page = const HomeMoviePage();
    case popularMoviesRoute:
      page = const PopularMoviesPage();
      cupertino = true;
    case topRatedMoviesRoute:
      page = const TopRatedMoviesPage();
      cupertino = true;
    case movieDetailRoute:
      page = MovieDetailPage(id: settings.arguments as int);
    case searchMoviesRoute:
      page = const SearchMoviesPage();
      cupertino = true;
    case homeTvRoute:
      page = const HomeTvPage();
    case onTheAirTvRoute:
      page = const OnTheAirTvPage();
      cupertino = true;
    case popularTvRoute:
      page = const PopularTvPage();
      cupertino = true;
    case topRatedTvRoute:
      page = const TopRatedTvPage();
      cupertino = true;
    case tvDetailRoute:
      page = TvDetailPage(id: settings.arguments as int);
    case tvSeasonDetailRoute:
      page = TvSeasonDetailPage(
        args: settings.arguments as TvSeasonDetailArguments,
      );
    case searchTvRoute:
      page = const SearchTvPage();
      cupertino = true;
    case watchlistRoute:
      page = const WatchlistPage();
    case aboutRoute:
      page = const AboutPage();
    default:
      page = const Scaffold(body: Center(child: Text('Page not found :(')));
  }

  return cupertino
      ? CupertinoPageRoute(builder: (_) => page, settings: settings)
      : MaterialPageRoute(builder: (_) => page, settings: settings);
}
