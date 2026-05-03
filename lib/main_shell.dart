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
  final List<bool> _hasBeenViewed = [false, false];

  static const List<Widget> _screens = [
    WorkoutScreen(),
    ReportScreen(),
  ];

  static const List<String> _titles = [
    'Workout',
    'Performance Report',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    // Guarantee the currently visible tab is marked as viewed
    if (!_hasBeenViewed[selectedIndex]) {
      _hasBeenViewed[selectedIndex] = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[selectedIndex]),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: List.generate(_screens.length, (index) {
          if (_hasBeenViewed[index]) {
            return _screens[index];
          }
          return const SizedBox.shrink();
        }),
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
        },
      ),
    );
  }
}
