import 'package:chatapp/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: rootPath,
    refreshListenable: Provider.of<AuthenticationProvider>(context, listen: false),
    redirect: (context, state) {
      final auth = Provider.of<AuthenticationProvider>(context, listen: false);
      final isLoggedIn = auth.user != null;
      final isLoginRoute = state.matchedLocation == rootPath;

      if (!isLoggedIn) {
        return isLoginRoute ? null : rootPath;
      }

      if (isLoggedIn && isLoginRoute) {
        return homePath;
      }

      return null;
    },
    routes: [
      GoRoute(path: rootPath, builder: (context, state) => const LoginScreen()),
      GoRoute(path: homePath, builder: (context, state) => const HomeScreen()),
      GoRoute(path: settingsPath, builder: (context, state) => const SettingsScreen()),
    ],
  );
}

//paths
const String rootPath = '/';
const String homePath = '/home';
const String settingsPath = '/settings';
