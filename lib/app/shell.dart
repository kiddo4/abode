import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../features/discover/discover_page.dart';
import '../features/saved/saved_page.dart';
import 'theme.dart';

/// Holds the two tabs behind the floating glass bar.
///
/// The glass chrome is the only place liquid glass appears — it needs content
/// moving underneath it to refract, and keeping it to the bar leaves the 3D as
/// the subject rather than competing with it.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Wraps the whole scaffold, not just the body: the tab bar's own labels
    // sit outside `body` and would otherwise keep the debug underline.
    return Material(
      type: MaterialType.transparency,
      child: GlassScaffold(
        backgroundColor: AbodeColors.canvas,
        body: IndexedStack(
          index: _index,
          children: const [DiscoverPage(), SavedPage()],
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _index,
          onTabSelected: (i) => setState(() => _index = i),
          selectedIconColor: AbodeColors.ink,
          unselectedIconColor: AbodeColors.inkTertiary,
          selectedLabelColor: AbodeColors.ink,
          unselectedLabelColor: AbodeColors.inkTertiary,
          tabs: const [
            GlassTab(icon: Icon(Icons.explore_outlined), label: 'Discover'),
            GlassTab(icon: Icon(Icons.bookmark_border_rounded), label: 'Saved'),
          ],
        ),
      ),
    );
  }
}
