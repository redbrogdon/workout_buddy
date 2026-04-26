import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/workout_screen.dart';
import 'screens/report_screen.dart';
import 'providers/navigation_providers.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late final PageController _pageController;

  static const List<Widget> _screens = [
    WorkoutScreen(),
    ReportScreen(),
  ];

  static const List<String> _titles = [
    'Workout',
    'Performance Report',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    // Sync PageController if index changed from elsewhere
    if (_pageController.hasClients &&
        _pageController.page?.round() != selectedIndex) {
      _pageController.animateToPage(
        selectedIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) =>
            ref.read(navigationIndexProvider.notifier).setIndex(index),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        },
      ),
    );
  }
}
