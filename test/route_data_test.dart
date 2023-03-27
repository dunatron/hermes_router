// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';

class _HermesRouteDataBuild extends HermesRouteData {
  const _HermesRouteDataBuild();
  @override
  Widget build(BuildContext context, HermesRouterState state) =>
      const SizedBox(key: Key('build'));
}

class _ShellRouteDataBuilder extends ShellRouteData {
  const _ShellRouteDataBuilder();

  @override
  Widget builder(
    BuildContext context,
    HermesRouterState state,
    Widget navigator,
  ) =>
      SizedBox(
        key: const Key('builder'),
        child: navigator,
      );
}

final HermesRoute _goRouteDataBuild = HermesRouteData.$route(
  path: '/build',
  factory: (HermesRouterState state) => const _HermesRouteDataBuild(),
);

final ShellRoute _shellRouteDataBuilder = ShellRouteData.$route(
  factory: (HermesRouterState state) => const _ShellRouteDataBuilder(),
  routes: <RouteBase>[
    HermesRouteData.$route(
      path: '/child',
      factory: (HermesRouterState state) => const _HermesRouteDataBuild(),
    ),
  ],
);

class _HermesRouteDataBuildPage extends HermesRouteData {
  const _HermesRouteDataBuildPage();
  @override
  Page<void> buildPage(BuildContext context, HermesRouterState state) =>
      const MaterialPage<void>(
        child: SizedBox(key: Key('buildPage')),
      );
}

class _ShellRouteDataPageBuilder extends ShellRouteData {
  const _ShellRouteDataPageBuilder();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    HermesRouterState state,
    Widget navigator,
  ) =>
      MaterialPage<void>(
        child: SizedBox(
          key: const Key('page-builder'),
          child: navigator,
        ),
      );
}

final HermesRoute _goRouteDataBuildPage = HermesRouteData.$route(
  path: '/build-page',
  factory: (HermesRouterState state) => const _HermesRouteDataBuildPage(),
);

final ShellRoute _shellRouteDataPageBuilder = ShellRouteData.$route(
  factory: (HermesRouterState state) => const _ShellRouteDataPageBuilder(),
  routes: <RouteBase>[
    HermesRouteData.$route(
      path: '/child',
      factory: (HermesRouterState state) => const _HermesRouteDataBuild(),
    ),
  ],
);

class _HermesRouteDataRedirectPage extends HermesRouteData {
  const _HermesRouteDataRedirectPage();
  @override
  FutureOr<String> redirect(BuildContext context, HermesRouterState state) =>
      '/build-page';
}

final HermesRoute _goRouteDataRedirect = HermesRouteData.$route(
  path: '/redirect',
  factory: (HermesRouterState state) => const _HermesRouteDataRedirectPage(),
);

final List<HermesRoute> _routes = <HermesRoute>[
  _goRouteDataBuild,
  _goRouteDataBuildPage,
  _goRouteDataRedirect,
];

void main() {
  group('HermesRouteData', () {
    testWidgets(
      'It should build the page from the overridden build method',
      (WidgetTester tester) async {
        final HermesRouter goRouter = HermesRouter(
          initialLocation: '/build',
          routes: _routes,
        );
        await tester.pumpWidget(MaterialApp.router(
          routeInformationProvider: goRouter.routeInformationProvider,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ));
        expect(find.byKey(const Key('build')), findsOneWidget);
        expect(find.byKey(const Key('buildPage')), findsNothing);
      },
    );

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final HermesRouter goRouter = HermesRouter(
          initialLocation: '/build-page',
          routes: _routes,
        );
        await tester.pumpWidget(MaterialApp.router(
          routeInformationProvider: goRouter.routeInformationProvider,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ));
        expect(find.byKey(const Key('build')), findsNothing);
        expect(find.byKey(const Key('buildPage')), findsOneWidget);
      },
    );
  });

  group('ShellRouteData', () {
    testWidgets(
      'It should build the page from the overridden build method',
      (WidgetTester tester) async {
        final HermesRouter goRouter = HermesRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _shellRouteDataBuilder,
          ],
        );
        await tester.pumpWidget(MaterialApp.router(
          routeInformationProvider: goRouter.routeInformationProvider,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ));
        expect(find.byKey(const Key('builder')), findsOneWidget);
        expect(find.byKey(const Key('page-builder')), findsNothing);
      },
    );

    testWidgets(
      'It should build the page from the overridden buildPage method',
      (WidgetTester tester) async {
        final HermesRouter goRouter = HermesRouter(
          initialLocation: '/child',
          routes: <RouteBase>[
            _shellRouteDataPageBuilder,
          ],
        );
        await tester.pumpWidget(MaterialApp.router(
          routeInformationProvider: goRouter.routeInformationProvider,
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ));
        expect(find.byKey(const Key('builder')), findsNothing);
        expect(find.byKey(const Key('page-builder')), findsOneWidget);
      },
    );
  });

  testWidgets(
    'It should redirect using the overridden redirect method',
    (WidgetTester tester) async {
      final HermesRouter goRouter = HermesRouter(
        initialLocation: '/redirect',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsOneWidget);
    },
  );

  testWidgets(
    'It should redirect using the overridden redirect method',
    (WidgetTester tester) async {
      final HermesRouter goRouter = HermesRouter(
        initialLocation: '/redirect-with-state',
        routes: _routes,
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationProvider: goRouter.routeInformationProvider,
        routeInformationParser: goRouter.routeInformationParser,
        routerDelegate: goRouter.routerDelegate,
      ));
      expect(find.byKey(const Key('build')), findsNothing);
      expect(find.byKey(const Key('buildPage')), findsNothing);
    },
  );
}
