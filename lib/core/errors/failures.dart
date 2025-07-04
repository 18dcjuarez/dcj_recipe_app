import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  final String? message;

  const ServerFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class CacheFailure extends Failure {
  final String? message;

  const CacheFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class NetworkFailure extends Failure {
  final String? message;

  const NetworkFailure({this.message = 'No internet connection'});

  @override
  List<Object> get props => [message ?? ''];
}

class NotFoundFailure extends Failure {
  final String? message;

  const NotFoundFailure({this.message = 'Recipe not found'});

  @override
  List<Object> get props => [message ?? ''];
}

class UnexpectedFailure extends Failure {
  final String? message;

  const UnexpectedFailure({this.message = 'An unexpected error occurred'});

  @override
  List<Object> get props => [message ?? ''];
}
