import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_response.dart';
import 'api_exceptions.dart';

/// HTTP Client wrapper with automatic error handling, retry logic,
/// and request/response interceptors.
class ApiClient {
  final ApiConfig _config;
  final http.Client _client;
  String? _authToken;

  ApiClient({
    ApiConfig? config,
    http.Client? client,
  })  : _config = config ?? ApiConfig(),
        _client = client ?? http.Client();

  /// Set JWT authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get current authentication token
  String? get authToken => _authToken;

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers for the request
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(_config.defaultHeaders);
    
    if (_authToken != null) {
      headers.addAll(_config.authHeaders(_authToken!));
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  /// Make GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _executeWithRetry(() async {
      final response = await _client
          .get(uri, headers: _getHeaders(additionalHeaders: headers))
          .timeout(Duration(seconds: _config.timeoutSeconds));
      
      return _handleResponse<T>(response, fromJson);
    });
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _executeWithRetry(() async {
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));
      
      return _handleResponse<T>(response, fromJson);
    });
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _executeWithRetry(() async {
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));
      
      return _handleResponse<T>(response, fromJson);
    });
  }

  /// Make PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _executeWithRetry(() async {
      final response = await _client
          .patch(
            uri,
            headers: _getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _config.timeoutSeconds));
      
      return _handleResponse<T>(response, fromJson);
    });
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    return _executeWithRetry(() async {
      final response = await _client
          .delete(uri, headers: _getHeaders(additionalHeaders: headers))
          .timeout(Duration(seconds: _config.timeoutSeconds));
      
      return _handleResponse<T>(response, fromJson);
    });
  }

  /// Build URI from endpoint and query parameters
  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final url = endpoint.startsWith('http') 
        ? endpoint 
        : '${_config.baseUrl}$endpoint';
    
    final uri = Uri.parse(url);
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    
    return uri;
  }

  /// Handle HTTP response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    // Check for successful status codes
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        
        // Handle both Map and List responses
        final Map<String, dynamic> jsonData;
        if (decoded is Map<String, dynamic>) {
          jsonData = decoded;
        } else if (decoded is List) {
          // Wrap list in expected format
          jsonData = {
            'success': true,
            'data': decoded,
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          throw ParseException(
            message: 'Unexpected response type',
            details: 'Expected Map or List, got ${decoded.runtimeType}',
          );
        }
        
        if (fromJson != null) {
          return ApiResponse<T>.fromJson(jsonData, fromJson);
        } else {
          // For generic responses without specific type
          return ApiResponse<T>.fromJson(
            jsonData,
            (data) => data as T,
          );
        }
      } catch (e) {
        throw ParseException(
          message: 'Failed to parse response',
          details: e.toString(),
        );
      }
    }

    // Handle error responses
    _handleErrorResponse(response);
    
    // This should never be reached due to _handleErrorResponse throwing
    throw UnknownException(
      message: 'Unexpected error occurred',
      details: response.body,
    );
  }

  /// Handle error HTTP responses
  void _handleErrorResponse(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Check if response has error object
      if (jsonData.containsKey('error')) {
        final error = jsonData['error'] as Map<String, dynamic>;
        final errorCode = error['code'] as String? ?? 'UNKNOWN_ERROR';
        final errorMessage = error['message'] as String? ?? 'An error occurred';
        
        throw ApiExceptionFactory.fromApiError(
          errorCode,
          errorMessage,
          statusCode: response.statusCode,
          details: error,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      
      // If we can't parse the error, use status code
      throw ApiExceptionFactory.fromStatusCode(
        response.statusCode,
        message: response.reasonPhrase,
        details: response.body,
      );
    }

    // Fallback error
    throw ApiExceptionFactory.fromStatusCode(
      response.statusCode,
      message: response.reasonPhrase,
      details: response.body,
    );
  }

  /// Execute request with retry logic
  Future<ApiResponse<T>> _executeWithRetry<T>(
    Future<ApiResponse<T>> Function() request,
  ) async {
    int attempts = 0;
    
    while (attempts < _config.maxRetries) {
      try {
        return await request();
      } on TimeoutException {
        attempts++;
        if (attempts >= _config.maxRetries) {
          throw TimeoutException(
            message: 'Request timeout after $attempts attempts',
          );
        }
        await Future.delayed(Duration(seconds: _config.retryDelaySeconds));
      } on http.ClientException catch (e) {
        attempts++;
        if (attempts >= _config.maxRetries) {
          throw NetworkException(
            message: 'Network error: ${e.message}',
            details: e.toString(),
          );
        }
        await Future.delayed(Duration(seconds: _config.retryDelaySeconds));
      } on ApiException {
        // Don't retry API exceptions (4xx, 5xx errors)
        rethrow;
      } catch (e) {
        attempts++;
        if (attempts >= _config.maxRetries) {
          throw UnknownException(
            message: 'Unknown error occurred',
            details: e.toString(),
          );
        }
        await Future.delayed(Duration(seconds: _config.retryDelaySeconds));
      }
    }

    throw UnknownException(message: 'Max retries exceeded');
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}
