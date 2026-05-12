import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/auth_access_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static const home = '/';
  static const auth = '/auth';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthAccessPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}
