import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/candidates/candidates_list_screen.dart';
import 'views/vote/vote_confirmation_screen.dart';
import 'views/vote/vote_success_screen.dart';
import 'views/results/results_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Votación EPIC - UC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.candidates: (context) => const CandidatesListScreen(),
        AppRoutes.voteConfirmation: (context) => const VoteConfirmationScreen(),
        AppRoutes.voteSuccess: (context) => const VoteSuccessScreen(),
        AppRoutes.results: (context) => const ResultsScreen(),
      },
    );
  }
}
