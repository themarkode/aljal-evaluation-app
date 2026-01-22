import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'data/services/auth_service.dart';

/// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global auth service instance for credential change listening
final AuthService globalAuthService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start real-time listener for credential changes (replaces 15-sec polling)
    _startCredentialListener();
  }

  @override
  void dispose() {
    globalAuthService.stopListeningToCredentialChanges();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Restart listener when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _startCredentialListener();
    }
  }

  /// Start real-time listener for password changes
  /// This is much more efficient than polling every 15 seconds
  void _startCredentialListener() {
    globalAuthService.startListeningToCredentialChanges(() async {
      // Password changed in Firebase - logout and navigate to login
      await globalAuthService.logout();
      _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil(
        RouteNames.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Al-Jal Evaluation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.initial,
      onGenerateRoute: AppRouter.generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'KW'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ar', 'KW'),
    );
  }
}
