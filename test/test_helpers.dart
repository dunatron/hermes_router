// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';

Future<HermesRouter> createHermesRouter(WidgetTester tester) async {
  final HermesRouter goRouter = HermesRouter(
    initialLocation: '/',
    routes: <HermesRoute>[
      HermesRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      HermesRoute(
        path: '/error',
        builder: (_, __) => TestErrorScreen(TestFailure('Exception')),
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: goRouter,
  ));
  return goRouter;
}

Widget fakeNavigationBuilder(
  BuildContext context,
  HermesRouterState state,
  Widget child,
) =>
    child;

class HermesRouterNamedLocationSpy extends HermesRouter {
  HermesRouterNamedLocationSpy({required super.routes});

  String? name;
  Map<String, String>? params;
  Map<String, dynamic>? queryParams;

  @override
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    this.name = name;
    this.params = params;
    this.queryParams = queryParams;
    return '';
  }
}

class HermesRouterHermesSpy extends HermesRouter {
  HermesRouterHermesSpy({required super.routes});

  String? myLocation;
  Object? extra;

  @override
  void go(String location, {Object? extra}) {
    myLocation = location;
    this.extra = extra;
  }
}

class HermesRouterHermesNamedSpy extends HermesRouter {
  HermesRouterHermesNamedSpy({required super.routes});

  String? name;
  Map<String, String>? params;
  Map<String, dynamic>? queryParams;
  Object? extra;

  @override
  void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    this.name = name;
    this.params = params;
    this.queryParams = queryParams;
    this.extra = extra;
  }
}

class HermesRouterPushSpy extends HermesRouter {
  HermesRouterPushSpy({required super.routes});

  String? myLocation;
  Object? extra;

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    myLocation = location;
    this.extra = extra;
    return Future<T?>.value(extra as T?);
  }
}

class HermesRouterPushNamedSpy extends HermesRouter {
  HermesRouterPushNamedSpy({required super.routes});

  String? name;
  Map<String, String>? params;
  Map<String, dynamic>? queryParams;
  Object? extra;

  @override
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    this.name = name;
    this.params = params;
    this.queryParams = queryParams;
    this.extra = extra;
    return Future<T?>.value(extra as T?);
  }
}

class HermesRouterPopSpy extends HermesRouter {
  HermesRouterPopSpy({required super.routes});

  bool popped = false;
  Object? poppedResult;

  @override
  void pop<T extends Object?>([T? result]) {
    popped = true;
    poppedResult = result;
  }
}

Future<HermesRouter> createRouter(
  List<RouteBase> routes,
  WidgetTester tester, {
  HermesRouterRedirect? redirect,
  String initialLocation = '/',
  Object? initialExtra,
  int redirectLimit = 5,
  GlobalKey<NavigatorState>? navigatorKey,
  HermesRouterWidgetBuilder? errorBuilder,
}) async {
  final HermesRouter goRouter = HermesRouter(
    routes: routes,
    redirect: redirect,
    initialLocation: initialLocation,
    initialExtra: initialExtra,
    redirectLimit: redirectLimit,
    errorBuilder: errorBuilder ??
        (BuildContext context, HermesRouterState state) =>
            TestErrorScreen(state.error!),
    navigatorKey: navigatorKey,
  );
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: goRouter,
    ),
  );
  return goRouter;
}

class TestErrorScreen extends DummyScreen {
  const TestErrorScreen(this.ex, {super.key});

  final Exception ex;
}

class HomeScreen extends DummyScreen {
  const HomeScreen({super.key});
}

class Page1Screen extends DummyScreen {
  const Page1Screen({super.key});
}

class Page2Screen extends DummyScreen {
  const Page2Screen({super.key});
}

class LoginScreen extends DummyScreen {
  const LoginScreen({super.key});
}

class FamilyScreen extends DummyScreen {
  const FamilyScreen(this.fid, {super.key});

  final String fid;
}

class FamiliesScreen extends DummyScreen {
  const FamiliesScreen({required this.selectedFid, super.key});

  final String selectedFid;
}

class PersonScreen extends DummyScreen {
  const PersonScreen(this.fid, this.pid, {super.key});

  final String fid;
  final String pid;
}

class DummyScreen extends StatelessWidget {
  const DummyScreen({
    this.queryParametersAll = const <String, dynamic>{},
    super.key,
  });

  final Map<String, dynamic> queryParametersAll;

  @override
  Widget build(BuildContext context) => const Placeholder();
}

Widget dummy(BuildContext context, HermesRouterState state) =>
    const DummyScreen();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<DummyStatefulWidget> createState() => DummyStatefulWidgetState();
}

class DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}

Future<void> simulateAndroidBackButton(WidgetTester tester) async {
  final ByteData message =
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute'));
  await tester.binding.defaultBinaryMessenger
      .handlePlatformMessage('flutter/navigation', message, (_) {});
}
