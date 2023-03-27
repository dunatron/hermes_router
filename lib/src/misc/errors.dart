// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Thrown when [HermesRouter] is used incorrectly.
class HermesError extends Error {
  /// Constructs a [HermesError]
  HermesError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'HermesError: $message';
}
