import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application.
/// Failures represent issues that occur at the domain layer,
/// signaling that a use case operation could not be completed successfully.
///
/// Subclasses should provide specific details about the nature of the failure.
///
/// It extends [Equatable] to allow for easy comparison of failure objects.
abstract class Failure extends Equatable {
  final String message;

  final Object error;

  /// A list of properties that define the uniqueness of the failure.
  /// Used by [Equatable] for comparison.
  final List<Object> properties;

  /// Constructs a [Failure] with an optional list of properties.
  const Failure({
    this.properties = const <Object>[],
    required this.error,
    required this.message,
  });

  @override
  List<Object> get props => properties;
}

/// Represents a failure originating from the server or a remote API call.
/// This typically indicates issues like invalid requests, internal server errors,
/// or API communication problems.
class ServerFailure extends Failure {
  /// Constructs a [ServerFailure] with a required [message].
  const ServerFailure({required super.message, required super.error});
}

/// Represents a failure related to local data caching operations.
/// This could occur due to issues like corrupted cache, no data found in cache,
/// or problems reading/writing to local storage.
class CacheFailure extends Failure {
  /// Constructs a [CacheFailure] with required [message] and [error] details.
  const CacheFailure({required super.message, required super.error});
}

/// Represents a failure related to network connectivity.
/// This typically indicates that the device has no active internet connection
/// or cannot reach the intended network resource.
class NetworkFailure extends Failure {
  /// Constructs a [NetworkFailure] with required [message] and [error] details.
  const NetworkFailure({required super.message, required super.error});
}

/// This can originate from various data sources (server, cache, local database).
/// It signifies that the query was valid, but no matching entity exists.
class NoDataFoundFailure extends Failure {
  /// Constructs a [NoDataFoundFailure] with a required [message] and [error] details.
  const NoDataFoundFailure({required super.message, required super.error});
}

/// Represents a failure related to auth process.
/// This typically indicates that something went wrong or user did not complete
/// auth process well
class AuthenticationFailure extends Failure {
  /// Constructs a [AuthenticationFailure] with required [message] and [error] details.
  const AuthenticationFailure({required super.message, required super.error});
}

/// Represents a failure related to AdMob operations.
/// This typically indicates issues like ad loading failures, initialization problems,
/// or ad display errors.
class AdMobFailure extends Failure {
  /// Constructs a [AdMobFailure] with required [message] and [error] details.
  const AdMobFailure({required super.message, required super.error});
}

class MagnetInstanceFailure extends Failure {
  const MagnetInstanceFailure({required super.message, required super.error});
}

/// Represents a failure related to validation errors.
/// This typically indicates that input data doesn't meet required criteria.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, required super.error});
}

/// Represents a failure related to resource conflicts.
/// This typically indicates that a resource already exists or conflicts with existing data.
class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, required super.error});
}

/// Represents a failure related to rate limiting.
/// This typically indicates that too many requests have been made in a short period.
class RateLimitFailure extends Failure {
  const RateLimitFailure({required super.message, required super.error});
}

/// Represents a failure related to authorization.
/// This typically indicates that the user does not have permission to perform an action.
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required super.message, required super.error});
}

/// Represents a failure when a requested resource is not found.
/// This typically indicates that the resource does not exist or has been deleted.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, required super.error});
}
