// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';
import 'package:hermes_router/src/delegate.dart';
import 'package:hermes_router/src/match.dart';
import 'package:hermes_router/src/misc/error_screen.dart';

Future<HermesRouter> createHermesRouter(
  WidgetTester tester, {
  Listenable? refreshListenable,
}) async {
  final HermesRouter router = HermesRouter(
    initialLocation: '/',
    routes: <HermesRoute>[
      HermesRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      HermesRoute(path: '/a', builder: (_, __) => const DummyStatefulWidget()),
      HermesRoute(
        path: '/error',
        builder: (_, __) => const ErrorScreen(null),
      ),
    ],
    refreshListenable: refreshListenable,
  );
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router,
  ));
  return router;
}

void main() {
  group('pop', () {
    testWidgets('removes the last element', (WidgetTester tester) async {
      final HermesRouter goRouter = await createHermesRouter(tester)
        ..push('/error');
      await tester.pumpAndSettle();

      final RouteMatch last = goRouter.routerDelegate.matches.matches.last;
      await goRouter.routerDelegate.popRoute();
      expect(goRouter.routerDelegate.matches.matches.length, 1);
      expect(goRouter.routerDelegate.matches.matches.contains(last), false);
    });

    testWidgets('pops more than matches count should return false',
        (WidgetTester tester) async {
      final HermesRouter goRouter = await createHermesRouter(tester)
        ..push('/error');
      await tester.pumpAndSettle();
      await goRouter.routerDelegate.popRoute();
      expect(await goRouter.routerDelegate.popRoute(), isFalse);
    });
  });

  group('push', () {
    testWidgets(
      'It should return different pageKey when push is called',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches[1].pageKey,
          const ValueKey<String>('/a-p0'),
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 3);
        expect(
          goRouter.routerDelegate.matches.matches[2].pageKey,
          const ValueKey<String>('/a-p1'),
        );
      },
    );
  });

  group('canPop', () {
    testWidgets(
      'It should return false if there is only 1 match in the stack',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);

        await tester.pumpAndSettle();
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(goRouter.routerDelegate.canPop(), false);
      },
    );
    testWidgets(
      'It should return true if there is more than 1 match in the stack',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester)
          ..push('/a');

        await tester.pumpAndSettle();
        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(goRouter.routerDelegate.canPop(), true);
      },
    );
  });

  group('pushReplacement', () {
    testWidgets('It should replace the last match with the given one',
        (WidgetTester tester) async {
      final HermesRouter goRouter = HermesRouter(
        initialLocation: '/',
        routes: <HermesRoute>[
          HermesRoute(path: '/', builder: (_, __) => const SizedBox()),
          HermesRoute(path: '/page-0', builder: (_, __) => const SizedBox()),
          HermesRoute(path: '/page-1', builder: (_, __) => const SizedBox()),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      goRouter.push('/page-0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatch first = goRouter.routerDelegate.matches.matches.first;
      final RouteMatch last = goRouter.routerDelegate.matches.last;
      goRouter.pushReplacement('/page-1');
      expect(goRouter.routerDelegate.matches.matches.length, 2);
      expect(
        goRouter.routerDelegate.matches.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.matches.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.matches.last as ImperativeRouteMatch<Object?>)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should return different pageKey when pushReplacement is called',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(
          goRouter.routerDelegate.matches.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/a-p0'),
        );

        goRouter.pushReplacement('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/a-p1'),
        );
      },
    );
  });

  group('pushReplacementNamed', () {
    testWidgets(
      'It should replace the last match with the given one',
      (WidgetTester tester) async {
        final HermesRouter goRouter = HermesRouter(
          initialLocation: '/',
          routes: <HermesRoute>[
            HermesRoute(path: '/', builder: (_, __) => const SizedBox()),
            HermesRoute(
                path: '/page-0',
                name: 'page0',
                builder: (_, __) => const SizedBox()),
            HermesRoute(
                path: '/page-1',
                name: 'page1',
                builder: (_, __) => const SizedBox()),
          ],
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: goRouter,
          ),
        );

        goRouter.pushNamed('page0');

        goRouter.routerDelegate.addListener(expectAsync0(() {}));
        final RouteMatch first = goRouter.routerDelegate.matches.matches.first;
        final RouteMatch last = goRouter.routerDelegate.matches.last;
        goRouter.pushReplacementNamed('page1');
        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.first,
          first,
          reason: 'The first match should still be in the list of matches',
        );
        expect(
          goRouter.routerDelegate.matches.last,
          isNot(last),
          reason: 'The last match should have been removed',
        );
        expect(
          goRouter.routerDelegate.matches.last,
          isA<RouteMatch>().having(
            (RouteMatch match) => (match.route as HermesRoute).name,
            'match.route.name',
            'page1',
          ),
          reason: 'The new location should have been pushed',
        );
      },
    );
  });

  group('replace', () {
    testWidgets('It should replace the last match with the given one',
        (WidgetTester tester) async {
      final HermesRouter goRouter = HermesRouter(
        initialLocation: '/',
        routes: <HermesRoute>[
          HermesRoute(path: '/', builder: (_, __) => const SizedBox()),
          HermesRoute(path: '/page-0', builder: (_, __) => const SizedBox()),
          HermesRoute(path: '/page-1', builder: (_, __) => const SizedBox()),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      goRouter.push('/page-0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatch first = goRouter.routerDelegate.matches.matches.first;
      final RouteMatch last = goRouter.routerDelegate.matches.last;
      goRouter.replace('/page-1');
      expect(goRouter.routerDelegate.matches.matches.length, 2);
      expect(
        goRouter.routerDelegate.matches.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.matches.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.matches.last as ImperativeRouteMatch<Object?>)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should use the same pageKey when replace is called (with the same path)',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(
          goRouter.routerDelegate.matches.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/a-p0'),
        );

        goRouter.replace('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/a-p0'),
        );
      },
    );

    testWidgets(
      'It should use the same pageKey when replace is called (with a different path)',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(
          goRouter.routerDelegate.matches.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/a-p0'),
        );

        goRouter.replace('/');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/a-p0'),
        );
      },
    );
  });

  group('replaceNamed', () {
    Future<HermesRouter> createHermesRouter(
      WidgetTester tester, {
      Listenable? refreshListenable,
    }) async {
      final HermesRouter router = HermesRouter(
        initialLocation: '/',
        routes: <HermesRoute>[
          HermesRoute(
            path: '/',
            name: 'home',
            builder: (_, __) => const SizedBox(),
          ),
          HermesRoute(
            path: '/page-0',
            name: 'page0',
            builder: (_, __) => const SizedBox(),
          ),
          HermesRoute(
            path: '/page-1',
            name: 'page1',
            builder: (_, __) => const SizedBox(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      return router;
    }

    testWidgets('It should replace the last match with the given one',
        (WidgetTester tester) async {
      final HermesRouter goRouter = await createHermesRouter(tester);

      goRouter.pushNamed('page0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatch first = goRouter.routerDelegate.matches.matches.first;
      final RouteMatch last = goRouter.routerDelegate.matches.last;
      goRouter.replaceNamed('page1');
      expect(goRouter.routerDelegate.matches.matches.length, 2);
      expect(
        goRouter.routerDelegate.matches.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.matches.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.matches.last as ImperativeRouteMatch<Object?>)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should use the same pageKey when replace is called with the same path',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(
          goRouter.routerDelegate.matches.matches.first.pageKey,
          isNotNull,
        );

        goRouter.pushNamed('page0');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/page-0-p0'),
        );

        goRouter.replaceNamed('page0');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/page-0-p0'),
        );
      },
    );

    testWidgets(
      'It should use a new pageKey when replace is called with a different path',
      (WidgetTester tester) async {
        final HermesRouter goRouter = await createHermesRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(
          goRouter.routerDelegate.matches.matches.first.pageKey,
          isNotNull,
        );

        goRouter.pushNamed('page0');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/page-0-p0'),
        );

        goRouter.replaceNamed('home');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const ValueKey<String>('/page-0-p0'),
        );
      },
    );
  });

  testWidgets('dispose unsubscribes from refreshListenable',
      (WidgetTester tester) async {
    final FakeRefreshListenable refreshListenable = FakeRefreshListenable();
    final HermesRouter goRouter =
        await createHermesRouter(tester, refreshListenable: refreshListenable);
    await tester.pumpWidget(Container());
    goRouter.dispose();
    expect(refreshListenable.unsubscribed, true);
  });
}

class FakeRefreshListenable extends ChangeNotifier {
  bool unsubscribed = false;

  @override
  void removeListener(VoidCallback listener) {
    unsubscribed = true;
    super.removeListener(listener);
  }
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
