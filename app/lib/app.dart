import 'package:flutter/material.dart';
import 'package:flightdeck/core/theme/app_theme.dart';
import 'package:flightdeck/features/flights/presentation/pages/splash_page.dart';

/// Root Application Widget configuring theme and home route.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlyWT',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
