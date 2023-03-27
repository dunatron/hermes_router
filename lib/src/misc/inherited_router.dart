// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../router.dart';

/// HermesRouter implementation of InheritedWidget.
///
/// Used for to find the current HermesRouter in the widget tree. This is useful
/// when routing from anywhere in your app.
class InheritedHermesRouter extends InheritedNotifier<HermesRouter> {
  /// Default constructor for the inherited go router.
  const InheritedHermesRouter({
    required super.child,
    required this.goRouter,
    super.key,
  }) : super(notifier: goRouter);

  /// The [HermesRouter] that is made available to the widget tree.
  final HermesRouter goRouter;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<HermesRouter>('goRouter', goRouter));
  }
}
