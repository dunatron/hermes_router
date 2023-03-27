// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';

import '../test_helpers.dart';

WidgetTesterCallback testPageNotFound({required Widget widget}) {
  return (WidgetTester tester) async {
    await tester.pumpWidget(widget);
    expect(find.text('page not found'), findsOneWidget);
  };
}

WidgetTesterCallback testPageShowsExceptionMessage({
  required Exception exception,
  required Widget widget,
}) {
  return (WidgetTester tester) async {
    await tester.pumpWidget(widget);
    expect(find.text('$exception'), findsOneWidget);
  };
}

WidgetTesterCallback testClickingTheButtonRedirectsToRoot({
  required Finder buttonFinder,
  required Widget widget,
  Widget Function(HermesRouter router) appRouterBuilder =
      materialAppRouterBuilder,
}) {
  return (WidgetTester tester) async {
    final HermesRouter router = HermesRouter(
      initialLocation: '/error',
      routes: <HermesRoute>[
        HermesRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
        HermesRoute(
          path: '/error',
          builder: (_, __) => widget,
        ),
      ],
    );
    await tester.pumpWidget(appRouterBuilder(router));
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DummyStatefulWidget), findsOneWidget);
  };
}

Widget materialAppRouterBuilder(HermesRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    title: 'HermesRouter Example',
  );
}

Widget cupertinoAppRouterBuilder(HermesRouter router) {
  return CupertinoApp.router(
    routerConfig: router,
    title: 'HermesRouter Example',
  );
}
