import 'dart:convert';
import 'dart:math';

import 'package:rollbar_common/rollbar_common.dart' hide isTrue;
import 'package:rollbar_dart/rollbar_dart.dart';
import 'package:test/test.dart';

enum Kind { trace, traces, message }

void main() {
  group('Payload serialization tests', () {
    Payload roundtrip(Payload p) =>
        Payload.fromMap(jsonDecode(jsonEncode(p.toMap())));

    test('Json roundtrip serialization test', () {
      final payloads = Kind.values.map(_Payload.gen).toList();
      final recovered = payloads.map(roundtrip).toList();

      payloads.zip(recovered).forEach((t) => expect(t.first, equals(t.second)));
      expect(payloads.zip(recovered).all((t) => t.first == t.second), isTrue);

      for (int x = 0; x < payloads.length; ++x) {
        for (int y = 0; y < recovered.length; ++y) {
          expect(payloads[x],
              (x == y) ? equals(recovered[y]) : isNot(equals(recovered[y])));
        }
      }
    });
  });
}

final rnd = Random(0x5f3759df);

// ignore: camel_case_extensions
extension _int on int {
  static int gen([int max = 1 << 32]) => rnd.nextInt(max);
}

extension _String on String {
  static String gen([int? len]) => rnd.nextString(len ?? _int.gen(24) + 8);
}

extension _Iterable<E> on Iterable<E> {
  static Iterable<E> gen<E>(E Function() gen) =>
      Iterable.generate(_int.gen(13) + 3, (_) => gen()).toList();
}

extension _Payload on Payload {
  static Payload gen(Kind kind) => Payload(
        data: _Data.gen(kind),
      );
}

extension _Reading on Reading {
  static Reading gen() => Reading.log(
        _String.gen(),
        extra: {'custom': _String.gen()},
        level: Level.values[_int.gen(Level.values.length)],
        source: Source.values[_int.gen(Source.values.length)],
      );
}

extension _Data on Data {
  static Data gen(Kind kind) => Data(
        body: _Body.gen(kind),
        timestamp: DateTime.now().toUtc(),
        language: _String.gen(),
        level: Level.values[_int.gen(Level.values.length)],
        platform: _String.gen(),
        framework: _String.gen(),
        codeVersion: _String.gen(),
        client: _Client.gen(),
        environment: _String.gen(),
        notifier: {'version': _String.gen(), 'name': _String.gen()},
        server: {'root': _String.gen()},
      );
}

extension _Body on Body {
  static Body gen(Kind kind) => Body(
        telemetry: _Iterable.gen(_Reading.gen),
        report: kind == Kind.message
            ? _Message.gen()
            : kind == Kind.trace
                ? _Trace.gen()
                : Traces(_Iterable.gen(_Trace.gen)) as Report,
      );
}

extension _Client on Client {
  static Client gen() => Client(
        locale: _String.gen(),
        hostname: _String.gen(),
        os: _String.gen(),
        osVersion: _String.gen(),
        dartVersion: _String.gen(),
        numberOfProcessors: rnd.nextInt(16) + 1,
      );
}

extension _ExceptionInfo on ExceptionInfo {
  static ExceptionInfo gen() => ExceptionInfo(
        type: _String.gen(),
        message: _String.gen(),
        description: _String.gen(),
      );
}

extension _Frame on Frame {
  static Frame gen() => Frame(
        filename: _String.gen(),
        type: _String.gen(),
        column: _int.gen(80),
        line: _int.gen(500),
        method: _String.gen(),
      );
}

extension _Trace on Trace {
  static Trace gen() => Trace(
        exception: _ExceptionInfo.gen(),
        frames: _Iterable.gen(_Frame.gen),
        rawTrace: _String.gen(),
      );
}

extension _Message on Message {
  static Message gen() => Message(
        text: _String.gen(),
      );
}
