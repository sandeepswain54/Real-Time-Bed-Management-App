# Bed Management API Architecture

## Overview

This is a production-grade Flutter API architecture implementing the **Repository/Service pattern** for the Bed Management application. It provides a clean, maintainable, and testable way to interact with the backend API at `https://bedmanagementupyogi.vercel.app/api`.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│           UI Layer (Screens)            │
│      - beds_screen.dart                 │
│      - dashboard_screen.dart            │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Services Layer                  │
│  - bed_service.dart                     │
│  - ward_service.dart                    │
│  - facility_service.dart                │
│  (Business logic & validation)          │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│       Repositories Layer                │
│  - bed_repository.dart                  │
│  - ward_repository.dart                 │
│  - facility_repository.dart             │
│  (Data access abstraction)              │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Network Layer                   │
│  - api_client.dart                      │
│  - api_response.dart                    │
│  - api_exceptions.dart                  │
│  (HTTP communication)                   │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│       Configuration                     │
│  - api_config.dart                      │
│  (Base URL, endpoints, headers)         │
└─────────────────────────────────────────┘
```

## Folder Structure

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart              # API configuration
│   └── network/
│       ├── api_client.dart              # HTTP client wrapper
│       ├── api_response.dart            # Response models
│       └── api_exceptions.dart          # Custom exceptions
├── data/
│   ├── models/
│   │   ├── bed_api_model.dart           # Bed model & DTOs
│   │   ├── ward_api_model.dart          # Ward model & DTOs
│   │   ├── facility_api_model.dart      # Facility model & DTOs
│   │   └── bed_stats_api_model.dart     # Statistics model
│   ├── repositories/
│   │   ├── bed_repository.dart          # Bed data access
│   │   ├── ward_repository.dart         # Ward data access
│   │   └── facility_repository.dart     # Facility data access
│   └── services/
│       ├── bed_service.dart             # Bed business logic
│       ├── ward_service.dart            # Ward business logic
│       └── facility_service.dart        # Facility business logic
└── screens/
    └── beds_screen.dart                 # UI implementation
```

## Features

### ✅ Core Features
- **Repository Pattern**: Clean separation between data access and business logic
- **Service Layer**: Centralized business logic and validation
- **Custom Exceptions**: Comprehensive error handling with specific exception types
- **Retry Logic**: Automatic retry with configurable attempts and delays
- **Pagination Support**: Built-in pagination handling
- **JWT Ready**: Prepared for authentication token integration
- **Type Safety**: Strongly-typed models with null safety

### ✅ Network Features
- Automatic request/response parsing
- Timeout configuration (30s default)
- Retry mechanism (3 retries, 2s delay)
- Comprehensive error handling
- Request interceptors ready
- Response validation

### ✅ Exception Handling
- `ApiException` - Base exception
- `NetworkException` - Network connectivity issues
- `TimeoutException` - Request timeouts
- `UnauthorizedException` - 401 errors
- `ForbiddenException` - 403 errors
- `NotFoundException` - 404 errors
- `ValidationException` - 400 validation errors
- `ServerException` - 5xx server errors
- And more...

## Installation

### 1. Add Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.0.5
```

Run:
```bash
flutter pub get
```

### 2. Configuration

The API is already configured in `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://bedmanagementupyogi.vercel.app/api';
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
}
```

## Usage Examples

### Basic Usage

#### 1. Fetch All Beds

```dart
import 'package:bed_app/data/services/bed_service.dart';

final bedService = BedService();

try {
  final bedsPage = await bedService.getAllBeds(
    page: 1,
    pageSize: 20,
  );
  
  print('Total beds: ${bedsPage.total}');
  print('Current page: ${bedsPage.page}');
  print('Has next: ${bedsPage.hasNext}');
  
  for (var bed in bedsPage.items) {
    print('Bed ${bed.bedNumber}: ${bed.status}');
  }
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

#### 2. Get Bed by ID

```dart
try {
  final bed = await bedService.getBedById('bed_123');
  print('Bed ${bed.bedNumber} in ${bed.wardName}');
} on NotFoundException catch (e) {
  print('Bed not found: ${e.message}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

#### 3. Filter Beds

```dart
// Get available beds in specific ward
final availableBeds = await bedService.getAvailableBeds(
  wardId: 'ward_1',
  facilityId: 'facility_1',
  page: 1,
  pageSize: 50,
);

// Get occupied beds
final occupiedBeds = await bedService.getOccupiedBeds(
  wardId: 'ward_1',
);
```

#### 4. Update Bed Status

```dart
try {
  final updatedBed = await bedService.updateBedStatus(
    'bed_123',
    'Cleaning',
  );
  print('Bed status updated to: ${updatedBed.status}');
} on ValidationException catch (e) {
  print('Invalid status: ${e.message}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

#### 5. Allocate Bed to Patient

```dart
try {
  final allocatedBed = await bedService.allocateBed(
    bedId: 'bed_123',
    patientId: 'patient_456',
    patientName: 'John Doe',
    checkInTime: DateTime.now(),
    expectedCheckOut: DateTime.now().add(Duration(days: 3)),
  );
  print('Bed allocated successfully');
} on ConflictException catch (e) {
  print('Bed is not available: ${e.message}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

#### 6. Get Bed Statistics

```dart
final stats = await bedService.getBedStats(
  facilityId: 'facility_1',
);

print('Total beds: ${stats.totalBeds}');
print('Available: ${stats.availableBeds}');
print('Occupied: ${stats.occupiedBeds}');
print('Occupancy rate: ${stats.occupancyRate}%');
```

### Ward Operations

```dart
import 'package:bed_app/data/services/ward_service.dart';

final wardService = WardService();

// Get all wards
final wardsPage = await wardService.getAllWards(
  facilityId: 'facility_1',
  page: 1,
  pageSize: 20,
);

// Get ward by ID
final ward = await wardService.getWardById('ward_1');
print('Ward: ${ward.name} - Occupancy: ${ward.occupancyRate}%');

// Create ward
final newWard = await wardService.createWard(
  CreateWardRequest(
    name: 'ICU Ward',
    facilityId: 'facility_1',
    floor: '3rd Floor',
    capacity: 20,
    description: 'Intensive Care Unit',
  ),
);

// Update ward
final updatedWard = await wardService.updateWard(
  'ward_1',
  UpdateWardRequest(
    capacity: 25,
  ),
);
```

### Facility Operations

```dart
import 'package:bed_app/data/services/facility_service.dart';

final facilityService = FacilityService();

// Get all facilities
final facilities = await facilityService.getAllFacilitiesList();

// Get facility by ID
final facility = await facilityService.getFacilityById('facility_1');
print('${facility.name} - Occupancy: ${facility.occupancyRate}%');

// Search facilities
final searchResults = await facilityService.searchFacilities(
  searchQuery: 'hospital',
  city: 'New York',
);

// Get facilities by city
final cityFacilities = await facilityService.getFacilitiesByCity('New York');
```

### Error Handling

```dart
try {
  final bed = await bedService.getBedById('bed_123');
} on UnauthorizedException catch (e) {
  // Handle unauthorized - redirect to login
  print('Please login: ${e.message}');
} on NotFoundException catch (e) {
  // Handle not found
  print('Bed not found: ${e.message}');
} on ValidationException catch (e) {
  // Handle validation errors
  print('Validation error: ${e.getAllFieldErrors()}');
} on NetworkException catch (e) {
  // Handle network issues
  print('Network error: ${e.message}');
} on ServerException catch (e) {
  // Handle server errors
  print('Server error: ${e.message}');
} on ApiException catch (e) {
  // Handle any other API errors
  print('API error: ${e.message}');
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

### With Provider State Management

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bed_app/data/services/bed_service.dart';

class BedApiProvider extends ChangeNotifier {
  final BedService _bedService = BedService();
  
  List<BedApiModel> _beds = [];
  bool _isLoading = false;
  String? _error;

  List<BedApiModel> get beds => _beds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBeds({String? wardId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _bedService.getAllBeds(
        wardId: wardId,
        status: status,
        page: 1,
        pageSize: 100,
      );
      
      _beds = response.items;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load beds';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBedStatus(String bedId, String status) async {
    try {
      final updatedBed = await _bedService.updateBedStatus(bedId, status);
      
      // Update local list
      final index = _beds.indexWhere((b) => b.id == bedId);
      if (index != -1) {
        _beds[index] = updatedBed;
        notifyListeners();
      }
      
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
```

Usage in widget:

```dart
class BedsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BedApiProvider()..loadBeds(),
      child: Consumer<BedApiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return CircularProgressIndicator();
          }

          if (provider.error != null) {
            return Text('Error: ${provider.error}');
          }

          return ListView.builder(
            itemCount: provider.beds.length,
            itemBuilder: (context, index) {
              final bed = provider.beds[index];
              return ListTile(
                title: Text('Bed ${bed.bedNumber}'),
                subtitle: Text('${bed.wardName} - ${bed.status}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Authentication (JWT)

To add JWT authentication:

```dart
import 'package:bed_app/core/network/api_client.dart';

final apiClient = ApiClient();

// Set token after login
apiClient.setAuthToken('your_jwt_token_here');

// Now all requests will include the Authorization header
final bedService = BedService(
  repository: BedRepository(apiClient: apiClient),
);

// Clear token on logout
apiClient.clearAuthToken();
```

## Testing

Create mock services for testing:

```dart
class MockBedService extends BedService {
  @override
  Future<PaginatedResponse<BedApiModel>> getAllBeds({
    String? wardId,
    String? facilityId,
    String? status,
    String? floor,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Return mock data
    return PaginatedResponse<BedApiModel>(
      items: [/* mock beds */],
      total: 10,
      page: 1,
      pageSize: 20,
      totalPages: 1,
      hasNext: false,
      hasPrevious: false,
    );
  }
}
```

## Best Practices

1. **Always handle exceptions**: Use try-catch with specific exception types
2. **Use services layer**: Don't call repositories directly from UI
3. **Pagination**: Use pagination for large datasets
4. **Error feedback**: Show user-friendly error messages
5. **Loading states**: Show loading indicators during API calls
6. **Validation**: Validate input before making API calls
7. **Caching**: Consider implementing caching at repository level for frequently accessed data

## API Response Format

The backend API uses this standardized format:

**Success Response:**
```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Paginated Response:**
```json
{
  "success": true,
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "totalPages": 5,
    "hasNext": true,
    "hasPrevious": false
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Migration from Mock Data

To migrate existing code from mock data to API:

```dart
// OLD WAY (Mock Data)
final beds = mockBeds;

// NEW WAY (API)
final bedService = BedService();
final bedsPage = await bedService.getAllBeds();
final beds = bedsPage.items;
```

## Future Enhancements

- [ ] Add caching layer in repositories
- [ ] Implement offline support
- [ ] Add request/response logging
- [ ] Implement refresh token mechanism
- [ ] Add GraphQL support
- [ ] WebSocket support for real-time updates
- [ ] Request queuing for offline mode

## Support

For issues or questions, refer to the API documentation at:
`https://bedmanagementupyogi.vercel.app/api/docs`

---

**Created with ❤️ for production-grade Flutter applications**
