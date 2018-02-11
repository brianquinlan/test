// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'compiler.dart';
import 'operating_system.dart';
import 'runtime.dart';

/// The platform on which a test suite is loaded.
class SuitePlatform {
  /// The runtime that hosts the suite.
  final Runtime runtime;

  /// The operating system on which the suite is running.
  ///
  /// This will always be [OperatingSystem.none] if `runtime.isBrowser` is
  /// `true`.
  final OperatingSystem os;

  /// The compiler with which the suite was compiled running.
  ///
  /// This will be [Compiler.none] if and only if `runtime.isDartVM` is `true`.
  final Compiler compiler;

  /// Creates a new platform with the given [runtime] and [os], which defaults
  /// to [OperatingSystem.none].
  ///
  /// Throws an [ArgumentError] if:
  ///
  /// * `runtime.isBrowser` is `true` and [os] is anything other than `null` or
  ///   [OperatingSystem.none].
  ///
  /// * `runtime.isDartVM` is `true` and [compiler] is anything other than
  ///   `null` or [Compiler.none].
  ///
  /// * `runtime.isDartVM` is `false` and [compiler] is `null` or
  ///   [Compiler.none].
  SuitePlatform(this.runtime, {OperatingSystem os, Compiler compiler})
      : os = os ?? OperatingSystem.none,
        compiler = compiler ?? Compiler.none {
    if (runtime.isBrowser && this.os != OperatingSystem.none) {
      throw new ArgumentError('No OS should be passed for runtime "$runtime".');
    }

    if (runtime.isDartVM) {
      if (this.compiler != Compiler.none) {
        throw new ArgumentError(
            'No compiler should be passed for runtime "$runtime".');
      }
    } else if (this.compiler == Compiler.none) {
      throw new ArgumentError(
          'A compiler must be passed for runtime "$runtime".');
    }
  }

  /// Converts a JSON-safe representation generated by [serialize] back into a
  /// [SuitePlatform].
  factory SuitePlatform.deserialize(Object serialized) {
    var map = serialized as Map;
    return new SuitePlatform(new Runtime.deserialize(map['runtime']),
        os: OperatingSystem.find(map['os']),
        compiler: Compiler.find(map['compiler']));
  }

  /// Converts [this] into a JSON-safe object that can be converted back to a
  /// [SuitePlatform] using [new SuitePlatform.deserialize].
  Object serialize() => {
        'runtime': runtime.serialize(),
        'os': os.identifier,
        'compiler': compiler.identifier
      };
}
