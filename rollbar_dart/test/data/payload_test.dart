import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:rollbar_common/rollbar_common.dart' hide isTrue;
import 'package:rollbar_dart/rollbar_dart.dart';
import 'package:test/test.dart';

enum Kind { trace, traces, message }

void main() {
  group('Payload equality and serialization tests', () {
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

    test('Manual deep equality test', () {
      final payloads = Kind.values.map(_Payload.gen).toList();
      final recovered = payloads.map(roundtrip).toList();

      for (final t in payloads.zip(recovered)) {
        final a = t.first, b = t.second;
        expect(a, equals(b));
        expect(a.data, equals(b.data));
        expect(a.data.body, equals(b.data.body));
        expect(a.data.client, equals(b.data.client));
        expect(a.data.client.dartVersion, equals(b.data.client.dartVersion));
        expect(a.data.client.hostname, equals(b.data.client.hostname));
        expect(a.data.client.locale, equals(b.data.client.locale));
        expect(a.data.client.numberOfProcessors,
            equals(b.data.client.numberOfProcessors));
        expect(a.data.client.os, equals(b.data.client.os));
        expect(a.data.client.osVersion, equals(b.data.client.osVersion));
        expect(a.data.codeVersion, equals(b.data.codeVersion));
        expect(a.data.custom, equals(b.data.custom));
        expect(DeepCollectionEquality().equals(a.data.custom, b.data.custom),
            isTrue);
        expect(a.data.environment, b.data.environment);
        expect(a.data.framework, equals(b.data.framework));
        expect(a.data.language, equals(b.data.language));
        expect(a.data.level, equals(b.data.level));
        expect(a.data.notifier, equals(b.data.notifier));
        expect(
            DeepCollectionEquality().equals(a.data.notifier, b.data.notifier),
            isTrue);
        expect(a.data.platform, equals(b.data.platform));
        expect(a.data.platformPayload, equals(b.data.platformPayload));
        expect(
            DeepCollectionEquality()
                .equals(a.data.platformPayload, b.data.platformPayload),
            isTrue);
        expect(a.data.server, equals(b.data.server)); // *map
        expect(DeepCollectionEquality().equals(a.data.server, b.data.server),
            isTrue);
        expect(a.data.timestamp, equals(b.data.timestamp));

        expect(a.data.body.telemetry, equals(b.data.body.telemetry));
        expect(
            DeepCollectionEquality()
                .equals(a.data.body.telemetry, b.data.body.telemetry),
            isTrue);
        expect(a.data.body.report, equals(b.data.body.report));

        for (final t in a.data.body.telemetry.zip(b.data.body.telemetry)) {
          expect(t.first, equals(t.second));
          expect(t.first.body, equals(t.second.body));
          expect(t.first.type, equals(t.second.type));
          expect(t.first.level, equals(t.second.level));
          expect(t.first.source, equals(t.second.source));
          expect(t.first.timestamp, equals(t.second.timestamp));
        }

        final ar = a.data.body.report, br = b.data.body.report;
        if (ar is Message && br is Message) {
          expect(ar, equals(br));
          expect(ar.text, equals(br.text));
        } else if (ar is Trace && br is Trace) {
          expect(ar, equals(br));
          _Trace.expectEqual(Tuple2(ar, br));
          ar.frames.zip(br.frames).forEach(_Frame.expectEqual);
        } else if (ar is Traces && br is Traces) {
          expect(ar, equals(br));
          for (final t in ar.traces.zip(br.traces)) {
            expect(t.first, equals(t.second));
            _Trace.expectEqual(t);
            t.first.frames.zip(t.second.frames).forEach(_Frame.expectEqual);
          }
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

  static void expectEqual(Tuple2<Frame, Frame> t) {
    expect(t.first.filename, equals(t.second.filename));
    expect(t.first.type, equals(t.second.type));
    expect(t.first.method, equals(t.second.method));
    expect(t.first.line, equals(t.second.line));
    expect(t.first.column, equals(t.second.column));
  }
}

extension _Trace on Trace {
  static Trace gen() => Trace(
        exception: _ExceptionInfo.gen(),
        frames: _Iterable.gen(_Frame.gen),
        rawTrace: _String.gen(),
      );

  static void expectEqual(Tuple2<Trace, Trace> t) {
    expect(t.first, equals(t.second));
    expect(t.first.rawTrace, equals(t.second.rawTrace));
    expect(t.first.exception, equals(t.second.exception));
    expect(t.first.exception.type, equals(t.second.exception.type));
    expect(t.first.exception.message, equals(t.second.exception.message));
    expect(
        t.first.exception.description, equals(t.second.exception.description));
    expect(t.first.frames, equals(t.second.frames));
  }
}

extension _Message on Message {
  static Message gen() => Message(
        text: _String.gen(),
      );
}
