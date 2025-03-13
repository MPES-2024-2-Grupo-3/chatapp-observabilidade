import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/analytics_service.dart';

import '../providers/auth_provider.dart';
import '../router.dart';
import 'users_list_screen.dart';
import 'placeholder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Log screen view for analytics
    AnalyticsService.logTelaInicio();
    // _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      // Get the token
      String? token = await messaging.getToken();
      if (token != null) {
        // TODO: Send this token to your server
        debugPrint('FCM Token: $token');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  List<_NavigationItem> get _navigationItems {
    final currentUserId = Provider.of<AuthenticationProvider>(context, listen: false).user?.uid ?? '';
    return [
      const _NavigationItem(screen: PlaceholderScreen(), icon: CupertinoIcons.search, title: 'Pesquisar'),
      const _NavigationItem(screen: PlaceholderScreen(), icon: CupertinoIcons.square_grid_2x2, title: 'Item 2'),
      _NavigationItem(screen: UsersListScreen(currentUserId: currentUserId), icon: CupertinoIcons.chat_bubble, title: 'Chat'),
      const _NavigationItem(screen: PlaceholderScreen(), icon: CupertinoIcons.bell, title: 'Notificações'),
      const _NavigationItem(screen: PlaceholderScreen(), icon: CupertinoIcons.ellipsis, title: 'Menu'),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Menu',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              onPressed: () {
                context.pop();
                context.go(settingsPath);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.settings, size: 22),
                  SizedBox(width: 8),
                  Text('Configurações',
                      style: TextStyle(fontSize: 17)),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Voltar',
                style: TextStyle(fontSize: 17)),
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthenticationProvider>(
          builder: (context, auth, _) {
            final firstName = auth.user?.displayName?.split(' ').first ?? '';
            return Text('Olá, $firstName');
          },
        ),
      ),
      body: _navigationItems[_selectedIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.title,
                ))
            .toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NavigationItem {
  final Widget screen;
  final IconData icon;
  final String title;

  const _NavigationItem({required this.screen, required this.icon, required this.title});
}