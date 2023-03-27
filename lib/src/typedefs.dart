// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async' show FutureOr;

import 'package:flutter/widgets.dart';

import 'configuration.dart';

/// The widget builder for [HermesRoute].
typedef HermesRouterWidgetBuilder = Widget Function(
  BuildContext context,
  HermesRouterState state,
);

/// The page builder for [HermesRoute].
typedef HermesRouterPageBuilder = Page<dynamic> Function(
  BuildContext context,
  HermesRouterState state,
);

/// The widget builder for [ShellRoute].
typedef ShellRouteBuilder = Widget Function(
  BuildContext context,
  HermesRouterState state,
  Widget child,
);

/// The page builder for [ShellRoute].
typedef ShellRoutePageBuilder = Page<dynamic> Function(
  BuildContext context,
  HermesRouterState state,
  Widget child,
);

/// The signature of the navigatorBuilder callback.
typedef HermesRouterNavigatorBuilder = Widget Function(
  BuildContext context,
  HermesRouterState state,
  Widget child,
);

/// Signature of a go router builder function with navigator.
typedef HermesRouterBuilderWithNav = Widget Function(
  BuildContext context,
  Widget child,
);

/// The signature of the redirect callback.
typedef HermesRouterRedirect = FutureOr<String?> Function(
    BuildContext context, HermesRouterState state);
