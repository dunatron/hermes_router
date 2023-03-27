// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/src/builder.dart';
import 'package:hermes_router/src/configuration.dart';
import 'package:hermes_router/src/match.dart';
import 'package:hermes_router/src/matching.dart';

void main() {
  group('RouteBuilder', () {
    testWidgets('Builds HermesRoute', (WidgetTester tester) async {
      final RouteConfiguration config = RouteConfiguration(
        routes: <RouteBase>[
          HermesRoute(
            path: '/',
            builder: (BuildContext context, HermesRouterState state) {
              return _DetailsScreen();
            },
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, HermesRouterState state) {
          return null;
        },
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      final RouteMatchList matches = RouteMatchList(
          <RouteMatch>[
            RouteMatch(
              route: config.routes.first as HermesRoute,
              subloc: '/',
              extra: null,
              error: null,
              pageKey: const ValueKey<String>('/'),
            ),
          ],
          Uri.parse('/'),
          const <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Builds ShellRoute', (WidgetTester tester) async {
      final RouteConfiguration config = RouteConfiguration(
        routes: <RouteBase>[
          ShellRoute(
              builder: (BuildContext context, HermesRouterState state,
                  Widget child) {
                return _DetailsScreen();
              },
              routes: <HermesRoute>[
                HermesRoute(
                  path: '/',
                  builder: (BuildContext context, HermesRouterState state) {
                    return _DetailsScreen();
                  },
                ),
              ]),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, HermesRouterState state) {
          return null;
        },
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      final RouteMatchList matches = RouteMatchList(
          <RouteMatch>[
            RouteMatch(
              route: config.routes.first,
              subloc: '/',
              extra: null,
              error: null,
              pageKey: const ValueKey<String>('/'),
            ),
          ],
          Uri.parse('/'),
          <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Uses the correct navigatorKey', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          HermesRoute(
            path: '/',
            builder: (BuildContext context, HermesRouterState state) {
              return _DetailsScreen();
            },
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, HermesRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
          <RouteMatch>[
            RouteMatch(
              route: config.routes.first as HermesRoute,
              subloc: '/',
              extra: null,
              error: null,
              pageKey: const ValueKey<String>('/'),
            ),
          ],
          Uri.parse('/'),
          <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder:
                (BuildContext context, HermesRouterState state, Widget child) {
              return _HomeScreen(
                child: child,
              );
            },
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[
              HermesRoute(
                path: '/details',
                builder: (BuildContext context, HermesRouterState state) {
                  return _DetailsScreen();
                },
              ),
            ],
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, HermesRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
          <RouteMatch>[
            RouteMatch(
              route: config.routes.first,
              subloc: '',
              extra: null,
              error: null,
              pageKey: const ValueKey<String>(''),
            ),
            RouteMatch(
              route: config.routes.first.routes.first,
              subloc: '/details',
              extra: null,
              error: null,
              pageKey: const ValueKey<String>('/details'),
            ),
          ],
          Uri.parse('/details'),
          <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_HomeScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(_DetailsScreen), findsOneWidget);
      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute with parentNavigatorKey',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder:
                (BuildContext context, HermesRouterState state, Widget child) {
              return _HomeScreen(
                child: child,
              );
            },
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[
              HermesRoute(
                path: '/a',
                builder: (BuildContext context, HermesRouterState state) {
                  return _DetailsScreen();
                },
                routes: <RouteBase>[
                  HermesRoute(
                    path: 'details',
                    builder: (BuildContext context, HermesRouterState state) {
                      return _DetailsScreen();
                    },
                    // This screen should stack onto the root navigator.
                    parentNavigatorKey: rootNavigatorKey,
                  ),
                ],
              ),
            ],
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, HermesRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
          <RouteMatch>[
            RouteMatch(
              route: config.routes.first.routes.first as HermesRoute,
              subloc: '/a/details',
              extra: null,
              error: null,
              pageKey: const ValueKey<String>('/a/details'),
            ),
          ],
          Uri.parse('/a/details'),
          <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      // The Details screen should be visible, but the HomeScreen should be
      // offstage (underneath) the DetailsScreen.
      expect(find.byType(_HomeScreen), findsNothing);
      expect(find.byType(_DetailsScreen), findsOneWidget);
    });
  });
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text('Home Screen'),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Details Screen'),
    );
  }
}

class _BuilderTestWidget extends StatelessWidget {
  _BuilderTestWidget({
    required this.routeConfiguration,
    required this.matches,
  }) : builder = _routeBuilder(routeConfiguration);

  final RouteConfiguration routeConfiguration;
  final RouteBuilder builder;
  final RouteMatchList matches;

  /// Builds a [RouteBuilder] for tests
  static RouteBuilder _routeBuilder(RouteConfiguration configuration) {
    return RouteBuilder(
      configuration: configuration,
      builderWithNav: (
        BuildContext context,
        Widget child,
      ) {
        return child;
      },
      errorPageBuilder: (
        BuildContext context,
        HermesRouterState state,
      ) {
        return MaterialPage<dynamic>(
          child: Text('Error: ${state.error}'),
        );
      },
      errorBuilder: (
        BuildContext context,
        HermesRouterState state,
      ) {
        return Text('Error: ${state.error}');
      },
      restorationScopeId: null,
      observers: <NavigatorObserver>[],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: builder.tryBuild(
          context,
          matches,
          (_, __) => false,
          false,
          routeConfiguration.navigatorKey,
          <Page<Object?>, HermesRouterState>{}),
      // builder: (context, child) => ,
    );
  }
}
