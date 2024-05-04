import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TabController tabController;
  final List<String> macAddresses;

  MyAppBar({required this.title, required this.tabController, required this.macAddresses});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text('$title (${tabController.index + 1}/${tabController.length})'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabs: macAddresses.map((macaddr) => Tab(text: macaddr)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}
