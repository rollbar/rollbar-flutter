import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

enum Source { client, server }

@sealed
@immutable
class Reading
    with EquatableSerializableMixin
    implements Equatable, Serializable {
  final String type;
  final Level level;
  final Source source;
  final JsonMap body;
  final DateTime timestamp;

  Reading._({
    DateTime? timestamp,
    required this.type,
    required this.level,
    required this.source,
    required this.body,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  factory Reading.fromMap(JsonMap map) => Reading._(
      type: map['type'],
      level: Level.values.firstWhere((level) => level.name == map['level']),
      source: Source.values.firstWhere((src) => src.name == map['source']),
      body: map['body'],
      timestamp: DateTime.fromMicrosecondsSinceEpoch(
        map['timestamp'],
        isUtc: true,
      ));

  factory Reading.log(
    String message, {
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Reading._(type: 'log', level: level, source: source, body: {
        'body': {'message': message, ...extra}
      });

  factory Reading.error(
    String message, {
    JsonMap extra = const {},
    Level level = Level.error,
    Source source = Source.client,
  }) =>
      Reading._(type: 'error', level: level, source: source, body: {
        'body': {'message': message, ...extra}
      });

  factory Reading.network(
    Uri url, {
    required HttpMethod method,
    required int statusCode,
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Reading._(type: 'network', level: level, source: source, body: {
        'body': {
          'url': url.toString(),
          'method': method.name,
          'status_code': statusCode,
          ...extra
        }
      });

  factory Reading.connectivity({
    required String status,
    JsonMap extra = const {},
    Level level = Level.error,
    Source source = Source.client,
  }) =>
      Reading._(type: 'connectivity', level: level, source: source, body: {
        'body': {'change': status, ...extra}
      });

  factory Reading.navigation({
    required String from,
    required String to,
    JsonMap extra = const {},
    Level level = Level.error,
    Source source = Source.client,
  }) =>
      Reading._(type: 'navigation', level: level, source: source, body: {
        'body': {'from': from, 'to': to, ...extra}
      });

  factory Reading.widget({
    required String element,
    JsonMap extra = const {},
    Level level = Level.error,
    Source source = Source.client,
  }) =>
      Reading._(type: 'dom', level: level, source: source, body: {
        'body': {'element': element, ...extra}
      });

  @override
  JsonMap toMap() => {
        'type': type,
        'level': level.name,
        'source': source.name,
        'timestamp': timestamp.microsecondsSinceEpoch,
        'body': body,
      };

  @override
  String toString() => 'Reading('
      'type: $type, '
      'level: $level, '
      'source: $source, '
      'body: $body, '
      'timestamp: $timestamp)';
}
