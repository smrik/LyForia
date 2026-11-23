import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lyforia/theme.dart';
import 'package:lyforia/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:lyforia/screens/diary_screen.dart';
import 'package:lyforia/pages/binge_eating_log_page.dart';
import 'package:lyforia/pages/check_in_page.dart';
import 'package:lyforia/pages/to_do_list_page.dart';
import 'package:lyforia/pages/analytics_page.dart';
import 'package:lyforia/pages/habit_tracker_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize with explicit options to avoid default-app ambiguity.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    assert(() {
      try {
        final app = Firebase.app();
        // Helpful during setup: confirm project id at runtime (non-sensitive).
        // Remove or silence in production as needed.
        // ignore: avoid_print
        print('Firebase project: ' + (app.options.projectId ?? 'unknown'));
      } catch (_) {}
      return true;
    }());
  } catch (_) {
    // If already initialized (hot reload), reuse existing app.
    try {
      Firebase.app();
    } catch (e) {
      rethrow;
    }
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Lyforia',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routes: {
            DiaryScreen.routeName: (_) => const DiaryScreen(),
          },
          home: const MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Lazily instantiate pages to reduce initial build cost.
  final List<Widget?> _pages = List<Widget?>.filled(5, null, growable: false);

  Widget _ensurePage(int index) {
    final existing = _pages[index];
    if (existing != null) return existing;
    late final Widget page;
    switch (index) {
      case 0:
        page = const CheckInPage();
        break;
      case 1:
        page = const BingeEatingLogPage();
        break;
      case 2:
        page = const ToDoListPage();
        break;
      case 3:
        page = const AnalyticsPage();
        break;
      case 4:
        page = HabitTrackerPage();
        break;
      default:
        page = const SizedBox.shrink();
    }
    _pages[index] = page;
    return page;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        itemBuilder: (context, index) => _ensurePage(index),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                _selectedIndex == 0 ? Icons.favorite : Icons.favorite_border),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                _selectedIndex == 1 ? Icons.fastfood : Icons.fastfood_outlined),
            label: 'Eating',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2
                ? Icons.check_circle
                : Icons.check_circle_outline),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 3
                ? Icons.analytics
                : Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 4 ? Icons.task : Icons.task_outlined),
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}
