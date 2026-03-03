/// API Configuration
/// 
/// Centralized configuration for all API endpoints and settings.
/// Production-ready with environment-specific settings.
class ApiConfig {
  // Base URL - Production deployment
  final String baseUrl;
  
  // API Version (if needed for future versioning)
  final String apiVersion;
  
  // Timeout durations in seconds
  final int timeoutSeconds;
  final int connectTimeoutSeconds;
  final int receiveTimeoutSeconds;
  
  // Retry configuration
  final int maxRetries;
  final int retryDelaySeconds;
  
  // Pagination defaults
  final int defaultPageSize;
  final int maxPageSize;
  
  // Endpoint paths
  final String bedsPath;
  final String wardsPath;
  final String facilitiesPath;
  final String bedStatsPath;
  
  ApiConfig({
    this.baseUrl = 'https://bedmanagementupyogi.vercel.app/api',
    this.apiVersion = 'v1',
    this.timeoutSeconds = 30,
    this.connectTimeoutSeconds = 30,
    this.receiveTimeoutSeconds = 30,
    this.maxRetries = 3,
    this.retryDelaySeconds = 2,
    this.defaultPageSize = 20,
    this.maxPageSize = 100,
    this.bedsPath = '/beds',
    this.wardsPath = '/wards',
    this.facilitiesPath = '/facilities',
    this.bedStatsPath = '/beds/stats',
  });
  
  // Headers
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Auth headers (prepared for JWT)
  Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  // Environment check
  bool get isProduction => true;
  
  // Full endpoint URLs
  String get bedsEndpoint => '$baseUrl$bedsPath';
  String get wardsEndpoint => '$baseUrl$wardsPath';
  String get facilitiesEndpoint => '$baseUrl$facilitiesPath';
  String get bedStatsEndpoint => '$baseUrl$bedStatsPath';
}
