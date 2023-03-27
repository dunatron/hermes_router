// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';

void main() {
  group('updateShouldNotify', () {
    test('does not update when goRouter does not change', () {
      final HermesRouter goRouter = HermesRouter(
        routes: <HermesRoute>[
          HermesRoute(
            path: '/',
            builder: (_, __) => const Page1(),
          ),
        ],
      );
      final bool shouldNotify = setupInheritedHermesRouterChange(
        oldHermesRouter: goRouter,
        newHermesRouter: goRouter,
      );
      expect(shouldNotify, false);
    });

    test('updates when goRouter changes', () {
      final HermesRouter oldHermesRouter = HermesRouter(
        routes: <HermesRoute>[
          HermesRoute(
            path: '/',
            builder: (_, __) => const Page1(),
          ),
        ],
      );
      final HermesRouter newHermesRouter = HermesRouter(
        routes: <HermesRoute>[
          HermesRoute(
            path: '/',
            builder: (_, __) => const Page2(),
          ),
        ],
      );
      final bool shouldNotify = setupInheritedHermesRouterChange(
        oldHermesRouter: oldHermesRouter,
        newHermesRouter: newHermesRouter,
      );
      expect(shouldNotify, true);
    });
  });

  test('adds [goRouter] as a diagnostics property', () {
    final HermesRouter goRouter = HermesRouter(
      routes: <HermesRoute>[
        HermesRoute(
          path: '/',
          builder: (_, __) => const Page1(),
        ),
      ],
    );
    final InheritedHermesRouter inheritedHermesRouter = InheritedHermesRouter(
      goRouter: goRouter,
      child: Container(),
    );
    final DiagnosticPropertiesBuilder properties =
        DiagnosticPropertiesBuilder();
    inheritedHermesRouter.debugFillProperties(properties);
    expect(properties.properties.length, 1);
    expect(
        properties.properties.first, isA<DiagnosticsProperty<HermesRouter>>());
    expect(properties.properties.first.value, goRouter);
  });

  testWidgets("mediates Widget's access to HermesRouter.",
      (WidgetTester tester) async {
    final MockHermesRouter router = MockHermesRouter();
    await tester.pumpWidget(MaterialApp(
        home:
            InheritedHermesRouter(goRouter: router, child: const _MyWidget())));
    await tester.tap(find.text('My Page'));
    expect(router.latestPushedName, 'my_page');
  });
}

bool setupInheritedHermesRouterChange({
  required HermesRouter oldHermesRouter,
  required HermesRouter newHermesRouter,
}) {
  final InheritedHermesRouter oldInheritedHermesRouter = InheritedHermesRouter(
    goRouter: oldHermesRouter,
    child: Container(),
  );
  final InheritedHermesRouter newInheritedHermesRouter = InheritedHermesRouter(
    goRouter: newHermesRouter,
    child: Container(),
  );
  return newInheritedHermesRouter.updateShouldNotify(
    oldInheritedHermesRouter,
  );
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) => Container();
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) => Container();
}

class _MyWidget extends StatelessWidget {
  const _MyWidget();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => context.pushNamed('my_page'),
        child: const Text('My Page'));
  }
}

class MockHermesRouter extends HermesRouter {
  MockHermesRouter() : super(routes: <HermesRoute>[]);

  late String latestPushedName;

  @override
  Future<T?> pushNamed<T extends Object?>(String name,
      {Map<String, String> params = const <String, String>{},
      Map<String, dynamic> queryParams = const <String, dynamic>{},
      Object? extra}) {
    latestPushedName = name;
    return Future<T?>.value();
  }

  @override
  BackButtonDispatcher get backButtonDispatcher => RootBackButtonDispatcher();
}
