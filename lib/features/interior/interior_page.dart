import 'package:flutter/material.dart';
import 'package:glint_engine/glint_engine.dart';

import '../../app/theme.dart';
import '../../data/interior/layout.dart';
import '../../data/interior/layouts.dart';
import '../../data/listing.dart';
import 'walk_controller.dart';

/// First-person walkthrough of a listing's interior.
///
/// [Scene3D] renders only the first model node it finds, so a room assembled
/// from ~90 kit pieces has to go through [GlintGameView] — which also gives the
/// free camera the walkthrough needs.
class InteriorPage extends StatefulWidget {
  const InteriorPage({super.key, required this.listing});

  final Listing listing;

  @override
  State<InteriorPage> createState() => _InteriorPageState();
}

class _InteriorPageState extends State<InteriorPage> {
  late final RoomLayout _layout;
  late final WalkController _walk;
  late final Map<String, Model> _models;
  late final List<GlintGameInstance> _instances;
  late final List<GlintGameInstance> _openInstances;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _layout = interiorLayouts[widget.listing.interiorLayoutId]!;
    _walk = WalkController(widget.listing.waypoints);
    _models = {
      for (final piece in _layout.pieces)
        piece: Model.asset('assets/models/kit/$piece.glb'),
    };
    // Placements are static, so instances are built once rather than per frame.
    _instances = [
      for (final p in _layout.placements)
        GlintGameInstance(model: p.piece, transform: p.transform),
    ];
    // The dollhouse view looks straight into the plan, so it drops the ceiling.
    _openInstances = [
      for (final p in _layout.placements)
        if (!p.isCeiling)
          GlintGameInstance(model: p.piece, transform: p.transform),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Render target sized to the screen rather than the 1024² default, so the
    // walkthrough is sharp without paying for pixels nobody sees.
    final width = (media.size.width * media.devicePixelRatio).round().clamp(
      320,
      1400,
    );
    final height = (media.size.height * media.devicePixelRatio).round().clamp(
      320,
      2400,
    );

    return Scaffold(
      backgroundColor: AbodeColors.ink,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => _walk.look(d.delta.dx, d.delta.dy),
              child: GlintGameView(
                models: _models,
                width: width,
                height: height,
                environmentAsset: 'assets/hdri/studio_small_09_1k.hdr',
                backgroundColor: const Color(0xFF11110E),
                lightDirection: const Vector3(0.35, -1, -0.45),
                lightIntensity: 2.2,
                ambientIntensity: 0.42,
                fogColor: const Color(0xFF11110E),
                fogDistance: 34,
                showStats: _showStats,
                fallback: const _GpuUnavailable(),
                onFrame: (dt) {
                  _walk.update(dt);
                  return GlintGameFrame(
                    camera: _walk.camera,
                    instances: _walk.currentIndex == 0
                        ? _openInstances
                        : _instances,
                  );
                },
              ),
            ),
          ),
          _TopBar(
            title: widget.listing.title,
            onClose: () => Navigator.of(context).pop(),
            onToggleStats: () => setState(() => _showStats = !_showStats),
            statsOn: _showStats,
          ),
          _RoomBar(
            waypoints: widget.listing.waypoints,
            controller: _walk,
            onSelect: (i) => setState(() => _walk.goTo(i)),
          ),
        ],
      ),
    );
  }
}

class _GpuUnavailable extends StatelessWidget {
  const _GpuUnavailable();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AbodeColors.ink,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(AbodeSpace.xl),
        child: Text(
          'Flutter GPU is unavailable on this device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontFamily: AbodeType.body),
        ),
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onClose,
    required this.onToggleStats,
    required this.statsOn,
  });

  final String title;
  final VoidCallback onClose;
  final VoidCallback onToggleStats;
  final bool statsOn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AbodeSpace.md,
          vertical: AbodeSpace.sm,
        ),
        child: Row(
          children: [
            _GlassCircleButton(icon: Icons.close_rounded, onTap: onClose),
            const SizedBox(width: AbodeSpace.md),
            Expanded(
              child: Text(
                title,
                style: AbodeType.title.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _GlassCircleButton(
              icon: Icons.speed_rounded,
              active: statsOn,
              onTap: onToggleStats,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AbodeColors.accent.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
    );
  }
}

class _RoomBar extends StatelessWidget {
  const _RoomBar({
    required this.waypoints,
    required this.controller,
    required this.onSelect,
  });

  final List<RoomWaypoint> waypoints;
  final WalkController controller;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AbodeSpace.lg),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AbodeSpace.md),
            child: Row(
              children: [
                for (var i = 0; i < waypoints.length; i++) ...[
                  _RoomChip(
                    label: waypoints[i].name,
                    selected: controller.currentIndex == i,
                    onTap: () => onSelect(i),
                  ),
                  if (i != waypoints.length - 1)
                    const SizedBox(width: AbodeSpace.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomChip extends StatelessWidget {
  const _RoomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AbodeRadius.chip),
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.13),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          style: AbodeType.label.copyWith(
            color: selected ? AbodeColors.ink : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
