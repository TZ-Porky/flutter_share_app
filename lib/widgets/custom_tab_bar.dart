import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController tabController;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: tabs.map((tabName) => Tab(text: tabName)).toList(),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Hauteur standard d'une TabBar
}