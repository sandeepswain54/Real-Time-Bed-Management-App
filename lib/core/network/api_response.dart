/// API Response Wrapper
/// 
/// Handles the standardized API response format from the backend.
/// 
/// Success Response:
/// ```json
/// {
///   "success": true,
///   "data": { ... },
///   "timestamp": "ISO_DATE"
/// }
/// ```
/// 
/// Error Response:
/// ```json
/// {
///   "success": false,
///   "error": {
///     "code": "ERROR_CODE",
///     "message": "Human readable message"
///   },
///   "timestamp": "ISO_DATE"
/// }
/// ```
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
  });

  /// Factory constructor for successful responses
  factory ApiResponse.fromSuccess(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null ? fromJson(json['data']) : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Factory constructor for error responses
  factory ApiResponse.fromError(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: false,
      error: ApiError.fromJson(json['error'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Factory constructor from generic JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final success = json['success'] as bool;
    
    if (success) {
      return ApiResponse.fromSuccess(json, fromJson);
    } else {
      return ApiResponse.fromError(json);
    }
  }

  /// Check if response is successful and has data
  bool get hasData => success && data != null;

  /// Get data or throw error
  T getData() {
    if (!success) {
      throw error ?? ApiError(code: 'UNKNOWN_ERROR', message: 'Unknown error occurred');
    }
    if (data == null) {
      throw ApiError(code: 'NO_DATA', message: 'No data in response');
    }
    return data!;
  }
}

/// API Error model
class ApiError {
  final String code;
  final String message;

  ApiError({
    required this.code,
    required this.message,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() => 'ApiError(code: $code, message: $message)';
}

/// Paginated API Response
/// 
/// Matches backend format:
/// {
///   "items": [...],
///   "pagination": {
///     "page": number,
///     "limit": number,
///     "total": number,
///     "totalPages": number
///   }
/// }
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => fromJsonItem(item as Map<String, dynamic>))
        .toList();

    final pagination = json['pagination'] as Map<String, dynamic>;

    return PaginatedResponse<T>(
      items: items,
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonItem) {
    return {
      'items': items.map(toJsonItem).toList(),
      'pagination': {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      },
    };
  }

  // Helper getters for common checks
  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;
  int get pageSize => limit; // Alias for backwards compatibility
}
