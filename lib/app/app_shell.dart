import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 下部タブを持つアプリ全体の枠。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'ホーム',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
      label: '学習',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_on_outlined),
      selectedIcon: Icon(Icons.grid_on_rounded),
      label: 'レンジ',
    ),
    NavigationDestination(
      icon: Icon(Icons.rate_review_outlined),
      selectedIcon: Icon(Icons.rate_review_rounded),
      label: 'レビュー',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'マイページ',
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // 同じタブをもう一度押したら、そのタブの先頭へ戻る。
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
