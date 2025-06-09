// lib/widgets/custom_tab_bar_secondary.dart
import 'package:flutter/material.dart';

class CustomTabBarSecondary extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController tabController;

  const CustomTabBarSecondary({
    super.key,
    required this.tabs,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: TabBar(
        controller: tabController,
        tabs: tabs.map((tabName) => Tab(text: tabName)).toList(),
        labelColor: Colors.white, // Labels des onglets blancs
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        indicatorColor: Colors.white, // Indicateur blanc
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}