import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/phone');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.brand,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                const BrandMark(size: 88, inverse: true),
                const SizedBox(height: 24),
                const Text(
                  'Livro Admin',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.ink, letterSpacing: -0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'GESTION DES LIVREURS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.4, color: AppTheme.ink.withValues(alpha: 0.65)),
                ),
                const Spacer(),
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.ink, strokeWidth: 2.5)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
