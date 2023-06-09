// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_router/hermes_router.dart';

void main() {
  test('throws when a builder is not set', () {
    expect(() => HermesRoute(path: '/'), throwsA(isAssertionError));
  });

  test('throws when a path is empty', () {
    expect(() => HermesRoute(path: ''), throwsA(isAssertionError));
  });

  test('does not throw when only redirect is provided', () {
    HermesRoute(path: '/', redirect: (_, __) => '/a');
  });
}
