---
name: flutter-expert-developer
description: A comprehensive Flutter development skill with deep expertise in all aspects of mobile app development using Flutter, covering widgets, state management, architecture, performance optimization, testing, animations, platform integration, and best practices from current industry standards.
when-to-use: When building, refactoring, debugging, or optimizing Flutter applications; when needing architectural guidance; when implementing complex UI components; when troubleshooting Flutter-specific issues; when setting up Flutter project structure or CI/CD pipelines.
capabilities:
  - Widget composition and custom widget development following Flutter's compositional patterns
  - State management implementation (Provider, Riverpod, BLoC, GetX, Redux, MobX)
  - Architecture pattern design and implementation (Clean Architecture, MVVM, MVC)
  - Performance optimization and profiling (widget rebuild reduction, const optimization, lazy loading)
  - Comprehensive testing strategy (unit tests, widget tests, integration tests, golden tests)
  - Animation creation and optimization (implicit, explicit, hero, staggered, physics-based)
  - Platform channel implementation for native iOS/Android communication
  - Responsive and adaptive UI design for mobile, tablet, web, and desktop
  - Accessibility implementation (semantics labels, screen reader support, contrast ratios)
  - Internationalization and localization (i18n/l10n) setup and implementation
  - Error handling and crash reporting integration (Sentry, Firebase Crashlytics)
  - Security best practices for Flutter applications
  - Firebase integration (Authentication, Firestore, Cloud Functions, Analytics)
  - CI/CD pipeline configuration for Flutter (Codemagic, GitHub Actions, Bitrise)
  - Dependency management and pub.dev package evaluation
  - Custom painting and complex canvas drawing operations
  - Navigation routing setup (Navigator 2.0, GoRouter, AutoRoute)
  - Asynchronous programming with Dart (Futures, Streams, async/await, isolates)
  - Memory management and leak detection/prevention
  - Build optimization for app size reduction and startup time
  - Platform-specific code implementation with conditional imports
  - Flutter web adaptation and optimization
  - Desktop application development (Windows, macOS, Linux)
  - Hot reload/restart troubleshooting and debugging
  - Widget testing with golden snapshot testing
  - Integration testing with automated test flows
  - Performance profiling using DevTools
  - Code organization and folder structure best practices
  - Design system implementation with theming and component libraries
  - Network operations and API integration (Dio, http, graphql_flutter)
  - Local data persistence (Hive, SQLite, SharedPreferences, Drift)
  - Push notification implementation (Firebase Cloud Messaging, OneSignal)
  - In-app purchase integration and subscription management
  - Deep linking and app indexing setup
  - Background task processing (WorkManager, flutter_background_service)
  - Image and asset optimization and caching strategies
---

# Flutter Expert Developer

A specialized skill for comprehensive Flutter development with 30+ years of combined mobile app development expertise, covering all aspects from widget composition to production deployment.

## Expertise Overview

This skill embodies deep knowledge accumulated from extensive Flutter development experience, staying current with the latest Flutter best practices, Dart language features, and mobile development patterns. It provides guidance across the entire development lifecycle.

## Core Development Principles

### 1. Widget Composition Over Inheritance

Always prefer composing smaller widgets rather than creating deep inheritance hierarchies. Each widget should have a single responsibility.

```dart
// ❌ Avoid: Monolithic widget doing too much
class ComplexUserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 50+ lines of avatar, name, bio, stats, buttons...
      ],
    );
  }
}

// ✅ Prefer: Composed, focused widgets
class UserProfile extends StatelessWidget {
  final User user;
  
  const UserProfile({super.key, required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(user: user),
        UserName(user: user),
        UserBio(user: user),
        UserStats(user: user),
        UserActions(user: user),
      ],
    );
  }
}
```

### 2. State Management Selection Guide

Choose the right state management solution based on project complexity and team size:

| Project Size | Recommended Solution | Rationale |
|-------------|---------------------|-----------|
| Small/Prototype | `setState` + Provider | Minimal boilerplate, easy to learn |
| Medium | Riverpod | Type-safe, testable, no BuildContext dependency |
| Large/Enterprise | BLoC/Cubit | Predictable state flow, excellent for complex business logic |
| Rapid Prototyping | GetX | Minimal code, fastest development speed |

**Example: Riverpod Implementation**

```dart
// State provider for simple values
final counterProvider = StateProvider<int>((ref) => 0);

// Async provider for data fetching
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});

// Notifier provider for complex state
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState.initial();
  
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

// Consumption in widget
class ProductList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    
    return productsAsync.when(
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### 3. Clean Architecture Implementation

Structure your Flutter application with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/ (or controllers, providers)
│   ├── pages/
│   ├── widgets/
│   └── routes/
└── main.dart
```

**Use Case Example:**

```dart
// Domain layer - use case
class GetUserProfileUseCase {
  final UserRepository repository;
  
  GetUserProfileUseCase(this.repository);
  
  Future<Either<Failure, User>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}

// Presentation layer - BLoC
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfile;
  
  UserProfileBloc(this.getUserProfile) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
  }
  
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    final result = await getUserProfile(event.userId);
    
    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (user) => emit(UserProfileLoaded(user)),
    );
  }
}
```

### 4. Performance Optimization Strategies

#### Const Constructors

Use `const` wherever possible to reduce widget rebuilds:

```dart
// ✅ Use const for static widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Static Title'),
        Icon(Icons.star),
      ],
    );
  }
}

// ✅ Extract const values
class ButtonStyles {
  static const elevatedButtonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );
}
```

#### ListView Optimization

```dart
// ✅ Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemExtent: 72, // Fixed height improves performance
  cacheExtent: 500, // Pre-render items off-screen
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// ✅ Use AutomaticKeepAliveClientMixin for stateful list items
class PersistentListItem extends StatefulWidget {
  @override
  _PersistentListItemState createState() => _PersistentListItemState();
}

class _PersistentListItemState extends State<PersistentListItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return ListTile(title: Text('Persistent'));
  }
}
```

#### RepaintBoundary Usage

```dart
// Wrap frequently animating widgets in RepaintBoundary
RepaintBoundary(
  child: AnimatedContainer(
    duration: Duration(milliseconds: 300),
    color: isPressed ? Colors.blue : Colors.grey,
    child: Text('Animated'),
  ),
)
```

### 5. Comprehensive Testing

#### Widget Tests with Golden Testing

```dart
// test/widget/profile_card_test.dart
void main() {
  testWidgets('ProfileCard renders user information', (tester) async {
    final user = User(
      name: 'John Doe',
      email: 'john@example.com',
      avatarUrl: 'https://example.com/avatar.jpg',
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileCard(user: user),
        ),
      ),
    );
    
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });
  
  testGoldens('ProfileCard golden test', (tester) async {
    final builder = GoldenBuilder.grid(
      columns: 2,
      widthToHeightRatio: 1,
    )
      ..addScenario('Default', ProfileCard(user: testUser))
      ..addScenario('With Long Name', ProfileCard(user: longNameUser))
      ..addScenario('Without Avatar', ProfileCard(user: noAvatarUser));
    
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(theme: ThemeData.light()),
    );
    
    await expectLater(
      find.byType(ProfileCard),
      matchesGoldenFile('goldens/profile_card.png'),
    );
  });
}
```

#### Integration Tests

```dart
// integration_test/app_test.dart
void main() {
  testWidgets('Full login flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // Navigate to login
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    
    // Enter credentials
    await tester.enterText(
      find.byKey(Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(Key('password_field')),
      'password123',
    );
    
    // Submit form
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    // Verify success
    expect(find.text('Welcome!'), findsOneWidget);
  });
}
```

### 6. Platform Channel Integration

```dart
// Method Channel Setup
class NativeHelper {
  static const platform = MethodChannel('com.example.app/native');
  
  static Future<String> getBatteryLevel() async {
    try {
      final level = await platform.invokeMethod('getBatteryLevel');
      return 'Battery level: $level%';
    } on PlatformException catch (e) {
      return 'Failed to get battery level: ${e.message}';
    }
  }
  
  static Future<void> openNativeSettings() async {
    try {
      await platform.invokeMethod('openSettings');
    } on PlatformException catch (e) {
      debugPrint('Error opening settings: ${e.message}');
    }
  }
}

// Event Channel for Streams
class LocationStream {
  static const eventChannel = EventChannel('com.example.app/location');
  
  static Stream<Map<String, double>> get locationStream {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, double>.from(event));
  }
}

// Usage in widget
class LocationWidget extends StatefulWidget {
  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = LocationStream.locationStream.listen((location) {
      setState(() {
        // Handle location updates
      });
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Build UI
  }
}
```

### 7. Responsive Design Implementation

```dart
// Responsive utilities
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1100 && desktop != null) {
      return desktop!;
    } else if (width >= 650 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// Usage
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: ProductLayoutMobile(),
        tablet: ProductLayoutTablet(),
        desktop: ProductLayoutDesktop(),
      ),
    );
  }
}

// Adaptive layout builder
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 1200) {
      return _buildWideLayout();
    } else if (constraints.maxWidth > 600) {
      return _buildMediumLayout();
    } else {
      return _buildCompactLayout();
    }
  },
)
```

### 8. Accessibility Implementation

```dart
// Semantic labels for screen readers
Semantics(
  label: 'Add item to shopping cart',
  button: true,
  onTap: () => _addToCart(),
  child: Icon(Icons.add_shopping_cart),
)

// Accessible form fields
TextField(
  decoration: InputDecoration(
    labelText: 'Email Address',
    hintText: 'Enter your email',
    errorText: _emailError,
  ),
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  onChanged: (value) => _validateEmail(value),
)

// Custom accessibility actions
class CustomAccessibleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Product card',
      hint: 'Double tap to view details, swipe left to delete',
      value: 'Nike Air Max, $129.99',
      increasedValue: 'Price increased to $139.99',
      decreasedValue: 'Price decreased to $119.99',
      onTap: () => _viewDetails(),
      onLongPress: () => _showContextMenu(),
      child: Card(
        child: ListTile(
          title: Text('Nike Air Max'),
          subtitle: Text('\$129.99'),
        ),
      ),
    );
  }
}

// Exclude from semantics
ExcludeSemantics(
  child: DecorativeIcon(),
)
```

### 9. Animation Patterns

#### Implicit Animations

```dart
// Simple implicit animation
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isExpanded ? Colors.blue : Colors.red,
  child: Center(child: Text('Tap me')),
)

// Animated cross-fade
AnimatedCrossFade(
  firstChild: Icon(Icons.check, size: 50),
  secondChild: Icon(Icons.close, size: 50),
  crossFadeState: _isSuccess 
      ? CrossFadeState.showFirst 
      : CrossFadeState.showSecond,
  duration: Duration(milliseconds: 300),
)
```

#### Explicit Animations (AnimationController)

```dart
class CustomAnimatedWidget extends StatefulWidget {
  @override
  _CustomAnimatedWidgetState createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
        ),
      ),
    );
  }
}
```

#### Hero Animations

```dart
// Source screen
Hero(
  tag: 'product-hero-${product.id}',
  child: ProductImage(product: product),
)

// Destination screen
Hero(
  tag: 'product-hero-${product.id}',
  child: ProductDetailImage(product: product),
)

// Custom hero animation
Hero(
  tag: 'custom-hero',
  createRectTween: (begin, end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  },
  flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 0.5,
          child: child,
        );
      },
    );
  },
  child: Container(...),
)
```

### 10. Navigation Implementation

#### Navigator 2.0 with GoRouter

```dart
// Router configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return ProfileScreen(userId: userId);
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoginRoute = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }
    return null;
  },
);

// Usage in MaterialApp
MaterialApp.router(
  routerConfig: router,
)

// Programmatic navigation
context.go('/profile/123');
context.push('/settings');
```

#### Deep Linking

```dart
// Android - AndroidManifest.xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="myapp" android:host="product" />
</intent-filter>

// iOS - Info.plist
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>

// Handle incoming links
class DeepLinkHandler {
  static final deepLinkStream = StreamController<Uri>.broadcast();
  
  static void initUniLinks() async {
    // App links
    final appLink = await getInitialLink();
    if (appLink != null) {
      deepLinkStream.add(Uri.parse(appLink));
    }
    
    // Listen for links while app is running
    uriLinkStream.listen((uri) {
      deepLinkStream.add(uri);
    });
  }
}

// Integration with GoRouter
final router = GoRouter(
  routes: [...],
  initialLocation: DeepLinkHandler.getInitialLocation(),
);
```

### 11. Error Handling & Crash Reporting

```dart
// Error boundary widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace stack)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });
  
  @override
  Widget build(BuildContext context) {
    return ErrorWidget.builder((details) {
      onError?.call(details.exception, details.stack);
      
      return Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => RestartWidget.restartApp(context),
                child: Text('Restart App'),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Global error handler
void main() {
  // Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Crashlytics.instance.recordError(
      details.exception,
      details.stack,
      fatal: true,
    );
  };
  
  // Async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    Crashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(MyApp());
}

// Safe async execution
extension SafeFuture on Future {
  static void safe<T>(
    Future<T> future, {
    void Function(T)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    future.then(
      (value) => onSuccess?.call(value),
      onError: (error, stackTrace) {
        onError?.call(error, stackTrace);
      },
    );
  }
}

// Usage
SafeFuture.safe(
  api.fetchData(),
  onSuccess: (data) => setState(() => _data = data),
  onError: (error, stack) => _showError(error),
);
```

### 12. Firebase Integration

```dart
// Firebase initialization
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Authentication
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AnalyticsService.logLogin('email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
    AnalyticsService.logLogout();
  }
}

// Firestore with streams
class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }
  
  Future<void> addProduct(Product product) async {
    await _firestore
        .collection('products')
        .add(product.toFirestore());
  }
}

// Cloud Functions
class CloudFunctionsService {
  static final functions = FirebaseFunctions.instance;
  
  static Future<String> createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    final callable = functions.httpsCallable('createPaymentIntent');
    
    final result = await callable.call({
      'amount': amount,
      'currency': currency,
    });
    
    return result.data['clientSecret'];
  }
}

// Remote Config
class RemoteConfigService {
  static final RemoteConfig _remoteConfig = RemoteConfig.instance;
  
  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(minutes: 1),
      minimumFetchInterval: Duration(hours: 1),
    ));
    
    await _remoteConfig.fetchAndActivate();
  }
  
  static bool get featureEnabled => _remoteConfig.getBool('new_feature_enabled');
  static String get apiUrl => _remoteConfig.getString('api_url');
}
```

### 13. Local Data Persistence

```dart
// Hive for simple key-value storage
class HiveService {
  static const String _boxName = 'app_storage';
  static late Box _box;
  
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }
  
  static Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }
  
  static String? getString(String key) => _box.get(key);
  
  static Future<void> setModel<T>(String key, T value) async {
    await _box.put(key, value);
  }
  
  static T? getModel<T>(String key) => _box.get(key);
}

// Drift (SQLite) for complex relational data
part 'database.g.dart';

@DriftDatabase(tables: [Products, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);
  
  @override
  int get schemaVersion => 1;
  
  Future<List<Product>> getAllProducts() => select(products).get();
  
  Future<Product> getProductById(int id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingle();
  
  Future<void> addProduct(Product product) => into(products).insert(product);
  
  Stream<List<Product>> watchProductsByCategory(int categoryId) {
    return (select(products)
          ..where((p) => p.categoryId.equals(categoryId))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }
}
```

### 14. CI/CD Pipeline Configuration

#### GitHub Actions for Flutter

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
      
  build-ios:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS (no codesigning)
        run: flutter build ios --release --no-codesign
```

### 15. Development Tools & Tips

#### Useful Extensions and Packages

```yaml
# pubspec.yaml recommended dev dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code generation
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.8
  
  # Linting
  flutter_lints: ^3.0.1
  
  # Testing
  mocktail: ^1.0.1
  integration_test:
    sdk: flutter
  golden_toolkit: ^0.15.0
  
  # Code coverage
  coverage: ^1.7.2
```

#### Recommended VS Code Extensions

1. **Flutter** - Official Flutter support
2. **Dart** - Dart language support
3. **Awesome Flutter Snippets** - Code snippets
4. **Flutter Widget Snippets** - Widget-specific snippets
5. **Error Lens** - Inline error display
6. **Bracket Pair Colorizer** - Visual bracket matching
7. **Import Cost** - Display package import sizes

## Best Practices Checklist

- [ ] All widgets use `const` constructors where possible
- [ ] State management is consistent across the project
- [ ] All async operations properly handle errors
- [ ] Widgets are small and focused (single responsibility)
- [ ] Build methods are kept simple (<100 lines)
- [ ] All network requests include timeout and error handling
- [ ] Images are optimized and cached appropriately
- [ ] Accessibility labels are provided for interactive elements
- [ ] Tests cover critical business logic
- [ ] Hardcoded strings are moved to localization files
- [ ] Environment configuration is externalized
- [ ] Sensitive data is not stored in plain text
- [ ] Memory leaks are prevented (dispose controllers, subscriptions)
- [ ] Navigation is type-safe (using GoRouter or similar)

## Common Anti-Patterns to Avoid

```dart
// ❌ Don't: Build method with complex logic
class BadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Don't do this!
    final data = expensiveComputation();
    final result = apiCall();
    return Container(...);
  }
}

// ✅ Do: Move logic to appropriate layers
class GoodWidget extends StatelessWidget {
  final Data data;
  
  const GoodWidget({super.key, required this.data});
  
  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}

// ❌ Don't: Context usage before build
class BadWidget extends StatefulWidget {
  @override
  _BadWidgetState createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  final theme = Theme.of(context); // Error: context not available
  
  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}

// ✅ Do: Use context in build or lifecycle methods
class GoodWidget extends StatefulWidget {
  @override
  _GoodWidgetState createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(...);
  }
}

// ❌ Don't: setState in build method
@override
Widget build(BuildContext context) {
  setState(() {}); // Infinite loop!
  return Container(...);
}

// ✅ Do: Use useEffect or lifecycle methods for side effects
@override
void initState() {
  super.initState();
  _initializeData();
}
```

## Performance Monitoring Checklist

- [ ] Use DevTools to identify widget rebuilds
- [ ] Profile app startup time
- [ ] Monitor memory usage and detect leaks
- [ ] Track janky frames (>16ms frame time)
- [ ] Analyze app size and remove unused assets
- [ ] Optimize image formats (WebP instead of PNG)
- [ ] Use `--split-debug-info` for release builds
- [ ] Enable code obfuscation for production
- [ ] Test on low-end devices for performance baselines

## Security Best Practices

```dart
// 1. Never store sensitive data in SharedPreferences/Hive
// Use flutter_secure_storage for sensitive data

final storage = FlutterSecureStorage();
await storage.write(key: 'api_key', value: secretKey);

// 2. Validate all inputs
class InputValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

// 3. Use certificate pinning for network requests
final dio = Dio();
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (cert, host, port) {
    return _isValidCertificate(cert);
  };
  return client;
};

// 4. Obfuscate production builds
// Run: flutter build apk --obfuscate --split-debug-info=./symbols

// 5. Use environment variables for configuration
const apiKey = String.fromEnvironment('API_KEY');
```

This Flutter Expert Developer skill provides comprehensive guidance for all aspects of Flutter development, from basic widget composition to complex enterprise-level applications. Always reference these patterns and best practices when working on Flutter projects.