// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/src/information_provider.dart';

const RouteInformation initialRoute = RouteInformation(location: '/');
const RouteInformation newRoute = RouteInformation(location: '/new');

void main() {
  group('HermesRouteInformationProvider', () {
    testWidgets('notifies its listeners when set by the app',
        (WidgetTester tester) async {
      late final HermesRouteInformationProvider provider =
          HermesRouteInformationProvider(initialRouteInformation: initialRoute);
      provider.addListener(expectAsync0(() {}));
      provider.value = newRoute;
    });

    testWidgets('notifies its listeners when set by the platform',
        (WidgetTester tester) async {
      late final HermesRouteInformationProvider provider =
          HermesRouteInformationProvider(initialRouteInformation: initialRoute);
      provider.addListener(expectAsync0(() {}));
      provider.didPushRouteInformation(newRoute);
    });
  });
}
