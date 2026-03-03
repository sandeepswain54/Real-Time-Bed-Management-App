# 🏥 Real-Time Bed Management Application

A production-grade Flutter mobile application for managing hospital bed allocations in real-time with an intuitive dashboard, analytics, and multi-facility support.

## ✨ Features

### Core Features
- **Real-Time Bed Management**: View and manage hospital beds across multiple wards
- **Bed Allocation System**: Allocate beds to patients with automatic status tracking
- **Multi-Facility Support**: Manage beds across different hospital facilities
- **Advanced Analytics**: View comprehensive statistics and bed utilization metrics
- **Ward Management**: Organize beds by wards with quick filtering
- **Patient Transfer System**: Transfer patients between beds seamlessly
- **Authentication**: Secure login system for authorized staff
- **Real-Time Status Updates**: Live bed status changes and availability

### UI/UX Features
- **Responsive Design**: Beautiful Material Design interface
- **Dark Theme Support**: Eye-friendly dark mode
- **Smooth Animations**: Fluid transitions and animations
- **Grid/List Views**: Multiple view modes for bed visualization
- **Loading States**: Progress indicators for data fetching
- **Error Handling**: Graceful error messages and retry mechanisms
- **Splash Screen**: Professional app launch experience

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter 3.10+**: Cross-platform mobile development
- **Dart 3.10+**: Programming language

### State Management
- **Provider 6.1.5+**: Reactive state management

### Networking
- **HTTP 1.1.0**: REST API communication
- **Dio-compatible**: Built for scalability

### UI Libraries
- **Google Fonts**: Typography
- **Font Awesome Flutter**: Icon library
- **Flutter SVG**: SVG asset support
- **FL Chart**: Advanced charts and analytics
- **Shimmer**: Loading placeholders
- **Animated Text Kit**: Text animations
- **Simple Animations**: Animation framework

### Tools
- **Intl 0.20.2**: Internationalization and date formatting
- **Flutter Lints**: Code quality analysis

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point
├── splashscreen.dart                   # Splash screen UI
├── Auth/
│   ├── login.dart                     # Login screen
│   └── dashboard.dart                 # User dashboard
├── core/
│   ├── config/
│   │   └── api_config.dart            # API configuration & endpoints
│   └── network/
│       ├── api_client.dart            # HTTP client wrapper
│       ├── api_response.dart          # Response models
│       └── api_exceptions.dart        # Custom exceptions
├── data/
│   ├── models/
│   │   ├── bed_api_model.dart         # Bed data models
│   │   ├── bed_model.dart             # Legacy bed model
│   │   ├── ward_api_model.dart        # Ward data models
│   │   ├── facility_api_model.dart    # Facility data models
│   │   ├── user_model.dart            # User data model
│   │   └── mock_data.dart             # Reference mock data
│   ├── repositories/
│   │   ├── bed_repository.dart        # Bed data access layer
│   │   ├── ward_repository.dart       # Ward data access layer
│   │   └── facility_repository.dart   # Facility data access layer
│   └── services/
│       ├── bed_service.dart           # Bed business logic
│       ├── ward_service.dart          # Ward business logic
│       └── facility_service.dart      # Facility business logic
├── providers/
│   ├── auth.dart                      # Authentication provider
│   ├── bed_provider.dart              # Bed state management
│   ├── bed_details.dart               # Bed details provider
│   ├── bed_grid.dart                  # Grid view provider
│   ├── bedallocation.dart             # Allocation logic
│   ├── facility.dart                  # Facility provider
│   ├── analysitc.dart                 # Analytics provider
│   ├── maintainacescareen.dart        # Maintenance screen provider
│   └── notification.dart              # Notifications provider
├── screens/
│   ├── beds_screen.dart               # Main beds display
│   ├── dashboard_screen.dart          # Alternative dashboard
│   ├── allocate_screen.dart           # Bed allocation form
│   ├── analytics_screen.dart          # Analytics visualization
│   └── ... (other screens)
├── Theme/
│   └── app_theme.dart                 # Theme configuration
├── Models/
│   ├── bed_model.dart                 # Bed model definition
│   ├── user_model.dart                # User model definition
│   └── mock_data.dart                 # Mock data for testing
└── examples/
    └── api_usage_examples.dart        # API usage examples

android/                               # Android-specific files
ios/                                   # iOS-specific files
web/                                   # Web platform files
linux/                                 # Linux platform files
macos/                                 # macOS platform files
windows/                               # Windows platform files
```

## 🏗️ Architecture

This application follows a **layered architecture** pattern:

```
┌─────────────────────────────┐
│     UI Layer (Screens)      │
│  - beds_screen.dart         │
│  - dashboard_screen.dart    │
│  - allocate_screen.dart     │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│    Providers (State)        │
│  - bed_provider.dart        │
│  - facility.dart            │
│  - analysitc.dart           │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│   Services (Business Logic) │
│  - bed_service.dart         │
│  - facility_service.dart    │
│  - ward_service.dart        │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│   Repositories (Data Access)│
│  - bed_repository.dart      │
│  - facility_repository.dart │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│    Network (HTTP Client)    │
│  - api_client.dart          │
│  - api_config.dart          │
└─────────────────────────────┘
```

### Architecture Benefits
- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Easy to unit and integration test
- **Reusability**: Services and repositories are reusable
- **Maintainability**: Clear structure makes code easy to navigate
- **Scalability**: Easy to add new features

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart SDK 3.10+
- Android Studio / Xcode (for emulator/device)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sandeepswain54/Real-Time-Bed-Management-App.git
   cd Real-Time-Bed-Management-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate necessary files (if required)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Running on Specific Platform
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d web
   
   # List available devices
   flutter devices
   ```

## 🌐 API Integration

The application is integrated with a production API at:
```
Base URL: https://bedmanagementupyogi.vercel.app/api
```

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/beds` | GET | Fetch all beds with pagination |
| `/beds/{id}` | GET | Get specific bed details |
| `/beds/{id}` | PUT | Update bed (allocate, release, transfer) |
| `/beds/{id}/status` | PUT | Update bed status |
| `/beds/stats` | GET | Get bed statistics |
| `/wards` | GET | Fetch all wards |
| `/wards/{facilityId}` | GET | Get wards by facility |
| `/facilities` | GET | Fetch all facilities |

### Network Features
- ✅ Automatic request/response parsing
- ✅ 30-second timeout configuration
- ✅ Automatic retry mechanism (3 retries, 2-second delay)
- ✅ Comprehensive error handling
- ✅ Request interceptors ready
- ✅ Response validation
- ✅ JWT authentication ready

### Exception Handling
The app implements custom exception handling:
- `ApiException` - Base exception
- `NetworkException` - Network connectivity issues
- `TimeoutException` - Request timeouts
- `UnauthorizedException` - 401 errors
- `ForbiddenException` - 403 errors
- `NotFoundException` - 404 errors
- `ServerException` - 500 errors

## 📱 Screens & Functionality

### 1. Splash Screen
- App introduction
- Initial loading
- Smooth animations

### 2. Login Screen
- User authentication
- Secure credential handling
- Session management

### 3. Dashboard
- Overview of bed statistics
- Quick access to main features
- Real-time status indicators
- Facility selector

### 4. Beds Screen
- Grid/list view of all beds
- Filter by ward and facility
- Color-coded bed status:
  - 🟢 Available
  - 🔴 Occupied
  - 🟡 Maintenance
  - ⚫ Reserved
- Quick allocation actions
- Bed details view

### 5. Allocate Screen
- Patient allocation form
- Ward and bed selection
- Patient information input
- Real-time allocation status

### 6. Analytics Screen
- Bed utilization metrics
- Ward-wise statistics
- Occupancy trends
- Availability forecasts

### 7. Dashboard Screen (Alternative)
- Enhanced statistics view
- Multiple facility support
- Detailed bed breakdown
- Performance metrics

## ⚙️ Configuration

### API Configuration
Edit `lib/core/config/api_config.dart`:
```dart
const String baseUrl = 'https://bedmanagementupyogi.vercel.app/api';
const Duration requestTimeOut = Duration(seconds: 30);
```

### Theme Configuration
Edit `lib/Theme/app_theme.dart` to customize:
- Color schemes
- Font styles
- Component styling
- Dark mode settings

### App Configuration
Edit `pubspec.yaml` to modify:
- App version
- Dependencies
- Assets
- Icons

## 💻 Development

### Build APK (Android)
```bash
flutter build apk --release
```

### Build AAB (Play Store)
```bash
flutter build appbundle --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

### Build Web
```bash
flutter build web --release
```

### Code Analysis
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Format Code
```bash
dart format lib/
```

## 🌍 Production API

The application connects to a live Bed Management API:

**Base URL**: `https://bedmanagementupyogi.vercel.app/api`

### Features
- Real-time data synchronization
- Multi-facility support
- Ward management
- Patient allocation tracking
- Analytics and reporting
- Role-based access control

### API Documentation
For detailed API documentation, refer to `lib/API_ARCHITECTURE_README.md`

## 📊 Recent Changes

### API Integration Migration (v1.0.0)
- ✅ Removed all mock data
- ✅ Integrated real API calls
- ✅ Updated BedProvider with async/await
- ✅ Enhanced error handling
- ✅ Added loading states
- ✅ Implemented pagination support
- ✅ Added analytics API integration

### Updated Screens
- Dashboard (showing real-time statistics)
- Beds Screen (real ward and bed data)
- Allocate Screen (live patient allocation)
- Analytics Screen (actual metrics)

See `API_INTEGRATION_SUMMARY.md` for detailed changes.

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Contribution Guidelines
- Follow Dart style guide
- Add proper documentation
- Test your changes
- Update README if needed
- Ensure no breaking changes

## 📝 License

This project is part of the Real-Time Bed Management System. All rights reserved.

## 👨‍💼 Author

**Sandeep Swain**
- GitHub: [@sandeepswain54](https://github.com/sandeepswain54)
- Repository: [Real-Time-Bed-Management-App](https://github.com/sandeepswain54/Real-Time-Bed-Management-App)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- All contributors and testers

## 📞 Support

For support, issues, or questions:
1. Open an issue on [GitHub Issues](https://github.com/sandeepswain54/Real-Time-Bed-Management-App/issues)
2. Check existing documentation
3. Review `lib/API_ARCHITECTURE_README.md`

## 🎯 Roadmap

- [ ] Offline data sync capability
- [ ] Push notifications for bed changes
- [ ] Enhanced reporting and export features
- [ ] Multi-language support
- [ ] Advanced scheduling system
- [ ] Mobile app performance optimization
- [ ] Backend API documentation

---

**Happy Coding! 🚀**
