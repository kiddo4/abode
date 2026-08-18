import 'package:flutter/material.dart';
import 'package:real_liquid_glass/real_liquid_glass.dart';

import '../features/discover/discover_page.dart';
import '../features/saved/saved_page.dart';
import 'theme.dart';

/// Holds the two tabs under a floating glass bar.
///
/// On iOS 26+ the bar hosts Apple's native `UIGlassEffect`, so it refracts the
/// real content behind it rather than approximating the material in a shader.
/// It has to float over the content in a [Stack] for that to mean anything —
/// glass with nothing behind it is just a grey rectangle.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbodeColors.canvas,
      // The bar overlays the body rather than insetting it, so listings scroll
      // under the glass.
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _index,
              children: const [DiscoverPage(), SavedPage()],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: LiquidGlassBottomBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                tint: AbodeColors.ink,
                margin: const EdgeInsets.symmetric(horizontal: AbodeSpace.md),
                items: const [
                  LiquidGlassBarItem(
                    icon: Icons.explore_outlined,
                    selectedIcon: Icons.explore,
                    sfSymbol: 'safari',
                    selectedSfSymbol: 'safari.fill',
                    label: 'Discover',
                  ),
                  LiquidGlassBarItem(
                    icon: Icons.bookmark_border_rounded,
                    selectedIcon: Icons.bookmark_rounded,
                    sfSymbol: 'bookmark',
                    selectedSfSymbol: 'bookmark.fill',
                    label: 'Saved',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
