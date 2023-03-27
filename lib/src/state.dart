// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'misc/errors.dart';

/// The route state during routing.
///
/// The state contains parsed artifacts of the current URI.
@immutable
class HermesRouterState {
  /// Default constructor for creating route state during routing.
  const HermesRouterState(
    this._configuration, {
    required this.location,
    required this.subloc,
    required this.name,
    this.path,
    this.fullpath,
    this.params = const <String, String>{},
    this.queryParams = const <String, String>{},
    this.queryParametersAll = const <String, List<String>>{},
    this.extra,
    this.error,
    required this.pageKey,
  });

  // TODO(johnpryan): remove once namedLocation is removed from go_router.
  // See https://github.com/flutter/flutter/issues/107729
  final RouteConfiguration _configuration;

  /// The full location of the route, e.g. /family/f2/person/p1
  final String location;

  /// The location of this sub-route, e.g. /family/f2
  final String subloc;

  /// The optional name of the route.
  final String? name;

  /// The path to this sub-route, e.g. family/:fid
  final String? path;

  /// The full path to this sub-route, e.g. /family/:fid
  final String? fullpath;

  /// The parameters for this sub-route, e.g. {'fid': 'f2'}
  final Map<String, String> params;

  /// The query parameters for the location, e.g. {'from': '/family/f2'}
  final Map<String, String> queryParams;

  /// The query parameters for the location,
  /// e.g. `{'q1': ['v1'], 'q2': ['v2', 'v3']}`
  final Map<String, List<String>> queryParametersAll;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// The error associated with this sub-route.
  final Exception? error;

  /// A unique string key for this sub-route.
  /// E.g.
  /// ```dart
  /// ValueKey('/family/:fid')
  /// ```
  final ValueKey<String> pageKey;

  /// Gets the [HermesRouterState] from context.
  ///
  /// The returned [HermesRouterState] will depends on which [HermesRoute] or
  /// [ShellRoute] the input `context` is in.
  ///
  /// This method only supports [HermesRoute] and [ShellRoute] that generate
  /// [ModalRoute]s. This is typically the case if one uses [HermesRoute.builder],
  /// [ShellRoute.builder], [CupertinoPage], [MaterialPage],
  /// [CustomTransitionPage], or [NoTransitionPage].
  ///
  /// This method is fine to be called during [HermesRoute.builder] or
  /// [ShellRoute.builder].
  ///
  /// This method cannot be called during [HermesRoute.pageBuilder] or
  /// [ShellRoute.pageBuilder] since there is no [HermesRouterState] to be
  /// associated with.
  ///
  /// To access HermesRouterState from a widget.
  ///
  /// ```
  /// HermesRoute(
  ///   path: '/:id'
  ///   builder: (_, __) => MyWidget(),
  /// );
  ///
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Text('${HermesRouterState.of(context).params['id']}');
  ///   }
  /// }
  /// ```
  static HermesRouterState of(BuildContext context) {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null) {
      throw HermesError('There is no modal route above the current context.');
    }
    final RouteSettings settings = route.settings;
    if (settings is! Page<Object?>) {
      throw HermesError(
          'The parent route must be a page route to have a HermesRouterState');
    }
    final HermesRouterStateRegistryScope? scope = context
        .dependOnInheritedWidgetOfExactType<HermesRouterStateRegistryScope>();
    if (scope == null) {
      throw HermesError(
          'There is no HermesRouterStateRegistryScope above the current context.');
    }
    final HermesRouterState state =
        scope.notifier!._createPageRouteAssociation(settings, route);
    return state;
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  @Deprecated('Use HermesRouter.of(context).namedLocation instead')
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
  }) {
    return _configuration.namedLocation(name,
        params: params, queryParams: queryParams);
  }

  @override
  bool operator ==(Object other) {
    return other is HermesRouterState &&
        other.location == location &&
        other.subloc == subloc &&
        other.name == name &&
        other.path == path &&
        other.fullpath == fullpath &&
        other.params == params &&
        other.queryParams == queryParams &&
        other.queryParametersAll == queryParametersAll &&
        other.extra == extra &&
        other.error == error &&
        other.pageKey == pageKey;
  }

  @override
  int get hashCode => Object.hash(location, subloc, name, path, fullpath,
      params, queryParams, queryParametersAll, extra, error, pageKey);
}

/// An inherited widget to host a [HermesRouterStateRegistry] for the subtree.
///
/// Should not be used directly, consider using [HermesRouterState.of] to access
/// [HermesRouterState] from the context.
class HermesRouterStateRegistryScope
    extends InheritedNotifier<HermesRouterStateRegistry> {
  /// Creates a HermesRouterStateRegistryScope.
  const HermesRouterStateRegistryScope({
    super.key,
    required HermesRouterStateRegistry registry,
    required super.child,
  }) : super(notifier: registry);
}

/// A registry to record [HermesRouterState] to [Page] relation.
///
/// Should not be used directly, consider using [HermesRouterState.of] to access
/// [HermesRouterState] from the context.
class HermesRouterStateRegistry extends ChangeNotifier {
  /// creates a [HermesRouterStateRegistry].
  HermesRouterStateRegistry();

  /// A [Map] that maps a [Page] to a [HermesRouterState].
  @visibleForTesting
  final Map<Page<Object?>, HermesRouterState> registry =
      <Page<Object?>, HermesRouterState>{};

  final Map<Route<Object?>, Page<Object?>> _routePageAssociation =
      <ModalRoute<Object?>, Page<Object?>>{};

  HermesRouterState _createPageRouteAssociation(
      Page<Object?> page, ModalRoute<Object?> route) {
    assert(route.settings == page);
    assert(registry.containsKey(page));
    final Page<Object?>? oldPage = _routePageAssociation[route];
    if (oldPage == null) {
      // This is a new association.
      _routePageAssociation[route] = page;
      // If there is an association, the registry relies on the route to remove
      // entry from registry because it wants to preserve the HermesRouterState
      // until the route finishes the popping animations.
      route.completed.then<void>((Object? result) {
        // Can't use `page` directly because Route.settings may have changed during
        // the lifetime of this route.
        final Page<Object?> associatedPage =
            _routePageAssociation.remove(route)!;
        assert(registry.containsKey(associatedPage));
        registry.remove(associatedPage);
      });
    } else if (oldPage != page) {
      // Need to update the association to avoid memory leak.
      _routePageAssociation[route] = page;
      assert(registry.containsKey(oldPage));
      registry.remove(oldPage);
    }
    assert(_routePageAssociation[route] == page);
    return registry[page]!;
  }

  /// Updates this registry with new records.
  void updateRegistry(Map<Page<Object?>, HermesRouterState> newRegistry) {
    bool shouldNotify = false;
    final Set<Page<Object?>> pagesWithAssociation =
        _routePageAssociation.values.toSet();
    for (final MapEntry<Page<Object?>, HermesRouterState> entry
        in newRegistry.entries) {
      final HermesRouterState? existingState = registry[entry.key];
      if (existingState != null) {
        if (existingState != entry.value) {
          shouldNotify =
              shouldNotify || pagesWithAssociation.contains(entry.key);
          registry[entry.key] = entry.value;
        }
        continue;
      }
      // Not in the _registry.
      registry[entry.key] = entry.value;
      // Adding or removing registry does not need to notify the listen since
      // no one should be depending on them.
    }
    registry.removeWhere((Page<Object?> key, HermesRouterState value) {
      if (newRegistry.containsKey(key)) {
        return false;
      }
      // For those that have page route association, it will be removed by the
      // route future. Need to notify the listener so they can update the page
      // route association if its page has changed.
      if (pagesWithAssociation.contains(key)) {
        shouldNotify = true;
        return false;
      }
      return true;
    });
    if (shouldNotify) {
      notifyListeners();
    }
  }
}
