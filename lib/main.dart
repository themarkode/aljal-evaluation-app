import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:aljal_evaluation/core/theme/app_theme.dart';
import 'package:aljal_evaluation/core/routing/app_router.dart';
import 'package:aljal_evaluation/core/routing/route_names.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Jal Evaluation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Routing configuration
      initialRoute: RouteNames.initial,
      onGenerateRoute: AppRouter.generateRoute,
      
      // RTL support for Arabic
      locale: const Locale('ar', 'KW'),
      supportedLocales: const [
        Locale('ar', 'KW'), // Arabic (Kuwait)
      ],
    );
  }
}