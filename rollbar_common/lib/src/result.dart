import 'package:meta/meta.dart';

abstract class Result<T, E extends Error /*| Exception*/ > {
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T get success => (this as Success<T, E>).value;
  E get failure => (this as Failure<T, E>).error;

  Result<U, E> map<U>(U Function(T) transform) => isSuccess
      ? Success(transform((this as Success<T, E>).value))
      : Failure((this as Failure<T, E>).error);
}

@sealed
@immutable
class Success<T, E extends Error> extends Result<T, E> {
  final T value;

  Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Success<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result.Success($value)';
}

@sealed
@immutable
class Failure<T, E extends Error> extends Result<T, E> {
  final E error;

  Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<T, E> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Result.Failure($error)';
}
