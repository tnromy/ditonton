import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app({required String currentRoute, List<String>? visited}) {
    Route<dynamic> route(RouteSettings settings) {
      visited?.add(settings.name!);
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => Scaffold(body: Text('page ${settings.name}')),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: AppDrawer(currentRoute: currentRoute),
        body: const Text('home'),
      ),
      onGenerateRoute: route,
    );
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  }

  group('AppDrawer', () {
    testWidgets('should show all menu items', (tester) async {
      await tester.pumpWidget(app(currentRoute: homeMovieRoute));
      await openDrawer(tester);

      expect(find.text('Ditonton'), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);
      expect(find.text('TV Series'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('should only close the drawer for the current home', (
      tester,
    ) async {
      final visited = <String>[];
      await tester.pumpWidget(
        app(currentRoute: homeMovieRoute, visited: visited),
      );
      await openDrawer(tester);
      await tester.tap(find.text('Movies'));
      await tester.pumpAndSettle();

      expect(visited, isEmpty);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('should replace the home when switching to TV Series', (
      tester,
    ) async {
      final visited = <String>[];
      await tester.pumpWidget(
        app(currentRoute: homeMovieRoute, visited: visited),
      );
      await openDrawer(tester);
      await tester.tap(find.text('TV Series'));
      await tester.pumpAndSettle();

      expect(visited, [homeTvRoute]);
      expect(find.text('page $homeTvRoute'), findsOneWidget);
    });

    for (final (menu, route) in [
      ('Watchlist', watchlistRoute),
      ('About', aboutRoute),
    ]) {
      testWidgets('should push $route when $menu is tapped', (tester) async {
        final visited = <String>[];
        await tester.pumpWidget(
          app(currentRoute: homeTvRoute, visited: visited),
        );
        await openDrawer(tester);
        await tester.tap(find.text(menu));
        await tester.pumpAndSettle();

        expect(visited, [route]);
        expect(find.text('page $route'), findsOneWidget);
      });
    }
  });

  testWidgets('SubHeading should show the title and call onTap', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubHeading(title: 'Popular', onTap: () => tapped++),
        ),
      ),
    );

    expect(find.text('Popular'), findsOneWidget);
    await tester.tap(find.text('See More'));
    expect(tapped, 1);
  });

  testWidgets('network image builders should render placeholder and error', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Column(
            children: [
              networkImagePlaceholder(context, 'url'),
              networkImageError(context, 'url', Exception()),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });
}
