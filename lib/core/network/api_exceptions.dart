/// Custom API Exceptions
/// 
/// Provides a comprehensive hierarchy of exceptions for API operations.
/// Allows for granular error handling throughout the application.

/// Base class for all API-related exceptions
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (code != null) buffer.write(' [code: $code]');
    if (statusCode != null) buffer.write(' [status: $statusCode]');
    if (details != null) buffer.write(' [details: $details]');
    return buffer.toString();
  }
}

/// Network connectivity exceptions
class NetworkException extends ApiException {
  NetworkException({
    String message = 'Network connection failed',
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_ERROR',
          details: details,
        );
}

/// No internet connection
class NoInternetException extends NetworkException {
  NoInternetException({
    String message = 'No internet connection available',
  }) : super(
          message: message,
          code: 'NO_INTERNET',
        );
}

/// Request timeout exceptions
class TimeoutException extends ApiException {
  TimeoutException({
    String message = 'Request timeout',
    dynamic details,
  }) : super(
          message: message,
          code: 'TIMEOUT',
          statusCode: 408,
          details: details,
        );
}

/// Unauthorized access (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    dynamic details,
  }) : super(
          message: message,
          code: 'UNAUTHORIZED',
          statusCode: 401,
          details: details,
        );
}

/// Forbidden access (403)
class ForbiddenException extends ApiException {
  ForbiddenException({
    String message = 'Access forbidden',
    dynamic details,
  }) : super(
          message: message,
          code: 'FORBIDDEN',
          statusCode: 403,
          details: details,
        );
}

/// Resource not found (404)
class NotFoundException extends ApiException {
  NotFoundException({
    String message = 'Resource not found',
    dynamic details,
  }) : super(
          message: message,
          code: 'NOT_FOUND',
          statusCode: 404,
          details: details,
        );
}

/// Validation errors (400)
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    String message = 'Validation failed',
    this.fieldErrors,
    dynamic details,
  }) : super(
          message: message,
          code: 'VALIDATION_ERROR',
          statusCode: 400,
          details: details ?? fieldErrors,
        );

  /// Get error message for a specific field
  String? getFieldError(String field) {
    final errors = fieldErrors?[field];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }

  /// Get all field errors as a single string
  String getAllFieldErrors() {
    if (fieldErrors == null || fieldErrors!.isEmpty) {
      return message;
    }
    final buffer = StringBuffer();
    fieldErrors!.forEach((field, errors) {
      buffer.writeln('$field: ${errors.join(', ')}');
    });
    return buffer.toString().trim();
  }
}

/// Conflict error (409)
class ConflictException extends ApiException {
  ConflictException({
    String message = 'Resource conflict',
    dynamic details,
  }) : super(
          message: message,
          code: 'CONFLICT',
          statusCode: 409,
          details: details,
        );
}

/// Server error (500)
class ServerException extends ApiException {
  ServerException({
    String message = 'Internal server error',
    int statusCode = 500,
    dynamic details,
  }) : super(
          message: message,
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          details: details,
        );
}

/// Service unavailable (503)
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException({
    String message = 'Service temporarily unavailable',
    dynamic details,
  }) : super(
          message: message,
          code: 'SERVICE_UNAVAILABLE',
          statusCode: 503,
          details: details,
        );
}

/// Too many requests (429)
class RateLimitException extends ApiException {
  final int? retryAfter; // seconds

  RateLimitException({
    String message = 'Too many requests',
    this.retryAfter,
    dynamic details,
  }) : super(
          message: message,
          code: 'RATE_LIMIT',
          statusCode: 429,
          details: details,
        );
}

/// Data parsing/serialization errors
class ParseException extends ApiException {
  ParseException({
    String message = 'Failed to parse response data',
    dynamic details,
  }) : super(
          message: message,
          code: 'PARSE_ERROR',
          details: details,
        );
}

/// Unknown/Unexpected errors
class UnknownException extends ApiException {
  UnknownException({
    String message = 'An unexpected error occurred',
    dynamic details,
  }) : super(
          message: message,
          code: 'UNKNOWN_ERROR',
          details: details,
        );
}

/// Exception factory to create appropriate exception from HTTP status code
class ApiExceptionFactory {
  static ApiException fromStatusCode(
    int statusCode, {
    String? message,
    String? code,
    dynamic details,
  }) {
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message ?? 'Bad request',
          details: details,
        );
      case 401:
        return UnauthorizedException(
          message: message ?? 'Unauthorized',
          details: details,
        );
      case 403:
        return ForbiddenException(
          message: message ?? 'Forbidden',
          details: details,
        );
      case 404:
        return NotFoundException(
          message: message ?? 'Not found',
          details: details,
        );
      case 408:
        return TimeoutException(
          message: message ?? 'Request timeout',
          details: details,
        );
      case 409:
        return ConflictException(
          message: message ?? 'Conflict',
          details: details,
        );
      case 429:
        return RateLimitException(
          message: message ?? 'Too many requests',
          details: details,
        );
      case 503:
        return ServiceUnavailableException(
          message: message ?? 'Service unavailable',
          details: details,
        );
      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message ?? 'Server error',
            statusCode: statusCode,
            details: details,
          );
        }
        return ApiException(
          message: message ?? 'Request failed',
          code: code ?? 'HTTP_$statusCode',
          statusCode: statusCode,
          details: details,
        );
    }
  }

  /// Create exception from API error response
  static ApiException fromApiError(
    String errorCode,
    String errorMessage, {
    int? statusCode,
    dynamic details,
  }) {
    // Map known error codes to specific exceptions
    switch (errorCode.toUpperCase()) {
      case 'UNAUTHORIZED':
      case 'AUTH_FAILED':
      case 'TOKEN_EXPIRED':
        return UnauthorizedException(message: errorMessage, details: details);
      
      case 'FORBIDDEN':
      case 'ACCESS_DENIED':
        return ForbiddenException(message: errorMessage, details: details);
      
      case 'NOT_FOUND':
      case 'RESOURCE_NOT_FOUND':
        return NotFoundException(message: errorMessage, details: details);
      
      case 'VALIDATION_ERROR':
      case 'INVALID_INPUT':
        return ValidationException(message: errorMessage, details: details);
      
      case 'CONFLICT':
      case 'DUPLICATE':
        return ConflictException(message: errorMessage, details: details);
      
      case 'RATE_LIMIT':
      case 'TOO_MANY_REQUESTS':
        return RateLimitException(message: errorMessage, details: details);
      
      case 'SERVER_ERROR':
      case 'INTERNAL_ERROR':
        return ServerException(message: errorMessage, details: details);
      
      case 'SERVICE_UNAVAILABLE':
      case 'MAINTENANCE':
        return ServiceUnavailableException(message: errorMessage, details: details);
      
      default:
        return ApiException(
          message: errorMessage,
          code: errorCode,
          statusCode: statusCode,
          details: details,
        );
    }
  }
}
