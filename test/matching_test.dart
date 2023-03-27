// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/src/configuration.dart';
import 'package:hermes_router/src/matching.dart';
import 'package:hermes_router/src/router.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('RouteMatchList toString prints the fullPath',
      (WidgetTester tester) async {
    final List<HermesRoute> routes = <HermesRoute>[
      HermesRoute(
          path: '/page-0',
          builder: (BuildContext context, HermesRouterState state) =>
              const Placeholder()),
    ];

    final HermesRouter router = await createRouter(routes, tester);
    router.go('/page-0');
    await tester.pumpAndSettle();

    final RouteMatchList matches = router.routerDelegate.matches;
    expect(matches.toString(), contains('/page-0'));
  });
}
