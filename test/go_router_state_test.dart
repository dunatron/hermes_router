// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';
import 'package:hermes_router/src/configuration.dart';

import 'test_helpers.dart';

void main() {
  group('HermesRouterState from context', () {
    testWidgets('works in builder', (WidgetTester tester) async {
      final List<HermesRoute> routes = <HermesRoute>[
        HermesRoute(
            path: '/',
            builder: (BuildContext context, _) {
              final HermesRouterState state = HermesRouterState.of(context);
              return Text('/ ${state.queryParams['p']}');
            }),
        HermesRoute(
            path: '/a',
            builder: (BuildContext context, _) {
              final HermesRouterState state = HermesRouterState.of(context);
              return Text('/a ${state.queryParams['p']}');
            }),
      ];
      final HermesRouter router = await createRouter(routes, tester);
      router.go('/?p=123');
      await tester.pumpAndSettle();
      expect(find.text('/ 123'), findsOneWidget);

      router.go('/a?p=456');
      await tester.pumpAndSettle();
      expect(find.text('/a 456'), findsOneWidget);
    });

    testWidgets('works in subtree', (WidgetTester tester) async {
      final List<HermesRoute> routes = <HermesRoute>[
        HermesRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text('1 ${HermesRouterState.of(context).location}');
              });
            },
            routes: <HermesRoute>[
              HermesRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(
                          '2 ${HermesRouterState.of(context).location}');
                    });
                  }),
            ]),
      ];
      final HermesRouter router = await createRouter(routes, tester);
      router.go('/?p=123');
      await tester.pumpAndSettle();
      expect(find.text('1 /?p=123'), findsOneWidget);

      router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('2 /a'), findsOneWidget);
      // The query parameter is removed, so is the location in first page.
      expect(find.text('1 /a', skipOffstage: false), findsOneWidget);
    });

    testWidgets('registry retains HermesRouterState for exiting route',
        (WidgetTester tester) async {
      final UniqueKey key = UniqueKey();
      final List<HermesRoute> routes = <HermesRoute>[
        HermesRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text(HermesRouterState.of(context).location);
              });
            },
            routes: <HermesRoute>[
              HermesRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(
                          key: key, HermesRouterState.of(context).location);
                    });
                  }),
            ]),
      ];
      final HermesRouter router =
          await createRouter(routes, tester, initialLocation: '/a?p=123');
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');
      final HermesRouterStateRegistry registry = tester
          .widget<HermesRouterStateRegistryScope>(
              find.byType(HermesRouterStateRegistryScope))
          .notifier!;
      expect(registry.registry.length, 2);
      router.go('/');
      await tester.pump();
      expect(registry.registry.length, 2);
      // should retain the same location even if the location has changed.
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');

      // Finish the pop animation.
      await tester.pumpAndSettle();
      expect(registry.registry.length, 1);
      expect(find.byKey(key), findsNothing);
    });

    testWidgets('imperative pop clears out registry',
        (WidgetTester tester) async {
      final UniqueKey key = UniqueKey();
      final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();
      final List<HermesRoute> routes = <HermesRoute>[
        HermesRoute(
            path: '/',
            builder: (_, __) {
              return Builder(builder: (BuildContext context) {
                return Text(HermesRouterState.of(context).location);
              });
            },
            routes: <HermesRoute>[
              HermesRoute(
                  path: 'a',
                  builder: (_, __) {
                    return Builder(builder: (BuildContext context) {
                      return Text(
                          key: key, HermesRouterState.of(context).location);
                    });
                  }),
            ]),
      ];
      await createRouter(routes, tester,
          initialLocation: '/a?p=123', navigatorKey: nav);
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');
      final HermesRouterStateRegistry registry = tester
          .widget<HermesRouterStateRegistryScope>(
              find.byType(HermesRouterStateRegistryScope))
          .notifier!;
      expect(registry.registry.length, 2);
      nav.currentState!.pop();
      await tester.pump();
      expect(registry.registry.length, 2);
      // should retain the same location even if the location has changed.
      expect(tester.widget<Text>(find.byKey(key)).data, '/a?p=123');

      // Finish the pop animation.
      await tester.pumpAndSettle();
      expect(registry.registry.length, 1);
      expect(find.byKey(key), findsNothing);
    });
  });
}
