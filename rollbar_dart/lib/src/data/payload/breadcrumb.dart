import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

enum Source { client, server }

@sealed
@immutable
class Breadcrumb
    with EquatableSerializableMixin, DebugStringRepresentation
    implements Equatable, Serializable {
  final String type;
  final Level level;
  final Source source;
  final JsonMap body;
  final DateTime timestamp;

  Breadcrumb._({
    DateTime? timestamp,
    required this.type,
    required this.level,
    required this.source,
    required this.body,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  factory Breadcrumb.fromMap(JsonMap map) => Breadcrumb._(
      type: map['type'],
      level: Level.values.firstWhere((level) => level.name == map['level']),
      source: Source.values.firstWhere((src) => src.name == map['source']),
      body: map['body'],
      timestamp: DateTime.fromMicrosecondsSinceEpoch(
        map['timestamp_ms'],
        isUtc: true,
      ));

  factory Breadcrumb.log(
    String message, {
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Breadcrumb._(type: 'log', level: level, source: source, body: {
        'message': message,
        ...extra,
      });

  factory Breadcrumb.error(
    String message, {
    JsonMap extra = const {},
    Level level = Level.error,
    Source source = Source.client,
  }) =>
      Breadcrumb._(type: 'error', level: level, source: source, body: {
        'message': message,
        ...extra,
      });

  factory Breadcrumb.network(
    Uri url, {
    required HttpMethod method,
    required int statusCode,
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Breadcrumb._(type: 'network', level: level, source: source, body: {
        'url': url.toString(),
        'method': method.name,
        'status_code': statusCode,
        ...extra,
      });

  factory Breadcrumb.connectivity({
    required String status,
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Breadcrumb._(type: 'connectivity', level: level, source: source, body: {
        'change': status,
        ...extra,
      });

  factory Breadcrumb.navigation({
    required String from,
    required String to,
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Breadcrumb._(type: 'navigation', level: level, source: source, body: {
        'from': from,
        'to': to,
        ...extra,
      });

  factory Breadcrumb.widget({
    required String element,
    JsonMap extra = const {},
    Level level = Level.info,
    Source source = Source.client,
  }) =>
      Breadcrumb._(type: 'dom', level: level, source: source, body: {
        'element': element,
        ...extra,
      });

  @override
  JsonMap toMap() => {
        'type': type,
        'level': level.name,
        'source': source.name,
        'timestamp_ms': timestamp.microsecondsSinceEpoch,
        'body': body,
      };
}
