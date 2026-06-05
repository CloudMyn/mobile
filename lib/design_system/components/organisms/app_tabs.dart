import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';

class AppTabItem {
  final String label;
  final IconData? icon;

  const AppTabItem({required this.label, this.icon});
}

class AppTabs extends StatelessWidget {
  final List<AppTabItem> tabs;
  final List<Widget> children;
  final bool isScrollable;
  final TabController? controller;

  const AppTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.isScrollable = false,
    this.controller,
  }) : assert(tabs.length == children.length);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          ColoredBox(
            color: colors.surface,
            child: TabBar(
              controller: controller,
              isScrollable: isScrollable,
              tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
              tabs: tabs.map((t) {
                if (t.icon != null) {
                  return Tab(text: t.label, icon: Icon(t.icon));
                }
                return Tab(text: t.label);
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
