import 'package:flutter/material.dart';
import 'package:glint_engine/glint_engine.dart';
import 'package:real_liquid_glass/real_liquid_glass.dart';

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
      backgroundColor: AbodeColors.interiorBackdrop,
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
                backgroundColor: AbodeColors.interiorBackdrop,
                lightDirection: const Vector3(0.35, -1, -0.45),
                lightIntensity: 2.2,
                ambientIntensity: 0.42,
                fogColor: AbodeColors.interiorBackdrop,
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
    color: AbodeColors.interiorBackdrop,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(AbodeSpace.xl),
        child: Text(
          'Flutter GPU is unavailable on this device.',
          textAlign: TextAlign.center,
          style: AbodeType.bodyText,
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
            Flexible(
              child: LiquidGlassContainer(
                shape: const LiquidGlassShape.capsule(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  title,
                  style: AbodeType.title.copyWith(color: AbodeColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Spacer(),
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
    return LiquidGlassContainer(
      onTap: onTap,
      width: 42,
      height: 42,
      shape: const LiquidGlassShape.capsule(),
      style: LiquidGlassStyle.regular,
      // LiquidGlassContainer does not centre its child by default, so with an
      // explicit width/height the icon otherwise sits in the top-left corner.
      alignment: Alignment.center,
      tint: active ? AbodeColors.accent : null,
      child: Icon(
        icon,
        size: 19,
        color: active ? Colors.white : AbodeColors.ink,
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
          padding: const EdgeInsets.only(bottom: AbodeSpace.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AbodeSpace.md),
            // One glass surface for the whole rail: a container per chip would
            // mean a native platform view per chip, layered over a live 3D
            // viewport.
            child: LiquidGlassContainer(
              shape: const LiquidGlassShape.capsule(),
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < waypoints.length; i++)
                    _RoomChip(
                      label: waypoints[i].name,
                      selected: controller.currentIndex == i,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawn inside the rail's glass, so the selected state is an opaque pill on
/// the material rather than a second sheet of glass on top of it.
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AbodeRadius.chip),
          color: selected ? Colors.white : Colors.transparent,
        ),
        child: Text(
          label,
          style: AbodeType.label.copyWith(
            // Ink rather than white: the glass takes its brightness from the
            // room behind it, and these interiors are light.
            color: selected
                ? AbodeColors.ink
                : AbodeColors.ink.withValues(alpha: 0.62),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
