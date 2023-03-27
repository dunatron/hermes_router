// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

import 'route.dart';
import 'state.dart';

/// A superclass for each route data
abstract class RouteData {
  /// Default const constructor
  const RouteData();
}

/// Baseclass for supporting
/// [Type-safe routing](https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html).
///
/// Subclasses must override one of [build], [buildPage], or
/// [redirect].
/// {@category Type-safe routes}
abstract class HermesRouteData extends RouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [HermesRouteData] is abstract and cannot be instantiated directly.
  const HermesRouteData();

  /// Creates the [Widget] for `this` route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [HermesRoute.builder].
  Widget build(BuildContext context, HermesRouterState state) =>
      throw UnimplementedError(
        'One of `build` or `buildPage` must be implemented.',
      );

  /// A page builder for this route.
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPage] or
  /// [redirect].
  ///
  /// Corresponds to [HermesRoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  Page<void> buildPage(BuildContext context, HermesRouterState state) =>
      const NoOpPage();

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [HermesRoute.redirect].
  FutureOr<String?> redirect(BuildContext context, HermesRouterState state) =>
      null;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static String $location(String path, {Map<String, dynamic>? queryParams}) =>
      Uri.parse(path)
          .replace(
            queryParameters:
                // Avoid `?` in generated location if `queryParams` is empty
                queryParams?.isNotEmpty ?? false ? queryParams : null,
          )
          .toString();

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static HermesRoute $route<T extends HermesRouteData>({
    required String path,
    required T Function(HermesRouterState) factory,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    T factoryImpl(HermesRouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `HermesRouteData`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(BuildContext context, HermesRouterState state) =>
        factoryImpl(state).build(context, state);

    Page<void> pageBuilder(BuildContext context, HermesRouterState state) =>
        factoryImpl(state).buildPage(context, state);

    FutureOr<String?> redirect(BuildContext context, HermesRouterState state) =>
        factoryImpl(state).redirect(context, state);

    return HermesRoute(
      path: path,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
    );
  }

  /// Used to cache [HermesRouteData] that corresponds to a given [HermesRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<HermesRouteData> _stateObjectExpando =
      Expando<HermesRouteData>(
    'HermesRouteState to HermesRouteData expando',
  );

  /// [navigatorKey] is used to point to a certain navigator
  ///
  /// It will use the given key to find the right navigator for [HermesRoute]
  GlobalKey<NavigatorState>? get navigatorKey => null;
}

/// Base class for supporting
/// [nested navigation](https://pub.dev/packages/go_router#nested-navigation)
abstract class ShellRouteData extends RouteData {
  /// Default const constructor
  const ShellRouteData();

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    HermesRouterState state,
    Widget navigator,
  ) =>
      const NoOpPage();

  /// [pageBuilder] is used to build the page
  Widget builder(
    BuildContext context,
    HermesRouterState state,
    Widget navigator,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static ShellRoute $route<T extends ShellRouteData>({
    required T Function(HermesRouterState) factory,
    GlobalKey<NavigatorState>? navigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    T factoryImpl(HermesRouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `HermesRouteData`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(
      BuildContext context,
      HermesRouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).builder(
          context,
          state,
          navigator,
        );

    Page<void> pageBuilder(
      BuildContext context,
      HermesRouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).pageBuilder(
          context,
          state,
          navigator,
        );

    return ShellRoute(
      builder: builder,
      pageBuilder: pageBuilder,
      routes: routes,
      navigatorKey: navigatorKey,
    );
  }

  /// Used to cache [ShellRouteData] that corresponds to a given [HermesRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<ShellRouteData> _stateObjectExpando =
      Expando<ShellRouteData>(
    'HermesRouteState to ShellRouteData expando',
  );

  /// It will be used to instantiate [Navigator] with the given key
  GlobalKey<NavigatorState>? get navigatorKey => null;
}

/// A superclass for each typed route descendant
class TypedRoute<T extends RouteData> {
  /// Default const constructor
  const TypedRoute();
}

/// A superclass for each typed go route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedHermesRoute<T extends HermesRouteData> extends TypedRoute<T> {
  /// Default const constructor
  const TypedHermesRoute({
    required this.path,
    this.routes = const <TypedRoute<RouteData>>[],
    this.parentNavigatorKey,
  });

  /// The path that corresponds to this route.
  ///
  /// See [HermesRoute.path].
  ///
  ///
  final String path;

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;

  /// {@macro go_router.HermesRoute.parentNavigatorKey}
  final GlobalKey<NavigatorState>? parentNavigatorKey;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedShellRoute<T extends ShellRouteData> extends TypedRoute<T> {
  /// Default const constructor
  const TypedShellRoute({
    this.routes = const <TypedRoute<RouteData>>[],
    this.navigatorKey,
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;

  /// {@macro go_router.ShellRoute.navigatorKey}
  final GlobalKey<NavigatorState>? navigatorKey;
}

/// Internal class used to signal that the default page behavior should be used.
@internal
class NoOpPage extends Page<void> {
  /// Creates an instance of NoOpPage;
  const NoOpPage();

  @override
  Route<void> createRoute(BuildContext context) =>
      throw UnsupportedError('Should never be called');
}
