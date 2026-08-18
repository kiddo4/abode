import 'dart:math' as math;

import 'package:glint_engine/glint_engine.dart';

/// One kit piece placed in the world.
///
/// Kenney's furniture kit is authored on a 1×1 metre grid: `floorFull` is a
/// 1×1 tile spanning `x ∈ [0,1], z ∈ [-1,0]`, and `wall` is 1 wide and 1.29
/// tall sitting on a tile edge. Everything here is expressed in that grid.
class Placement {
  const Placement({
    required this.piece,
    required this.position,
    this.yaw = 0,
    this.scale = Vector3.one,
    this.isCeiling = false,
  });

  /// Kit piece name without extension, e.g. `loungeSofa`.
  final String piece;
  final Vector3 position;

  /// Rotation about Y in radians.
  final double yaw;
  final Vector3 scale;

  /// Ceiling tiles are dropped in the dollhouse view so the plan reads from
  /// above, and restored once you are standing inside.
  final bool isCeiling;

  Transform3D get transform => Transform3D(
    position: position,
    rotation: Vector3(0, yaw, 0),
    scale: scale,
  );
}

class RoomLayout {
  const RoomLayout({
    required this.id,
    required this.placements,
    required this.pieces,
  });

  final String id;
  final List<Placement> placements;

  /// Distinct piece names, so the viewport can preload exactly what it needs.
  final Set<String> pieces;
}

/// Grid-oriented builder for a floor plan.
///
/// Tile `(c, r)` covers `x ∈ [c, c+1]` and `z ∈ [-(r+1), -r]`, matching how the
/// kit's floor tiles are authored. Walls sit on tile edges: [wallX] runs along
/// the x axis, [wallZ] along z.
class PlanBuilder {
  PlanBuilder();

  final List<Placement> _placements = [];

  /// The kit is internally consistent but not metric: a sofa is 0.98 units
  /// long against a 1.29-unit wall, so a wall reads as roughly storey height
  /// and one tile as roughly a stride. Pieces are therefore placed at native
  /// scale — stretching the walls to "real" metres would desync them from the
  /// furniture. [eyeHeight] is derived from the same proportion.
  static const wallHeightScale = 1.0;
  static const wallHeight = 1.29 * wallHeightScale;

  /// Standing eye level. Low enough under the 1.29 wall top to leave visible
  /// headroom once the ceiling is on.
  static const eyeHeight = 0.78;

  static const _wallScale = Vector3(1, wallHeightScale, 1);

  void add(
    String piece,
    double x,
    double z, {
    double yaw = 0,
    Vector3 scale = Vector3.one,
  }) {
    _placements.add(
      Placement(
        piece: piece,
        position: Vector3(x, 0, z),
        yaw: yaw,
        scale: scale,
      ),
    );
  }

  /// Places a piece resting on a surface above the floor (a table top, a shelf).
  void addAt(
    String piece,
    double x,
    double y,
    double z, {
    double yaw = 0,
    Vector3 scale = Vector3.one,
  }) {
    _placements.add(
      Placement(
        piece: piece,
        position: Vector3(x, y, z),
        yaw: yaw,
        scale: scale,
      ),
    );
  }

  /// Fills a rectangle of floor tiles, columns `[c0, c1)` and rows `[r0, r1)`.
  void floor(int c0, int r0, int c1, int r1) {
    for (var c = c0; c < c1; c++) {
      for (var r = r0; r < r1; r++) {
        add('floorFull', c.toDouble(), -r.toDouble());
      }
    }
  }

  /// Caps the same rectangle with a ceiling at wall height. Without it the kit
  /// leaves rooms open to the sky, which reads as broken geometry from inside.
  void ceiling(int c0, int r0, int c1, int r1) {
    for (var c = c0; c < c1; c++) {
      for (var r = r0; r < r1; r++) {
        _placements.add(
          Placement(
            piece: 'floorFull',
            position: Vector3(c.toDouble(), wallHeight, -r.toDouble()),
            isCeiling: true,
          ),
        );
      }
    }
  }

  /// A wall running along x at the edge `z = -r`, covering columns `[c0, c1)`.
  /// [openings] lists columns that use [openPiece] instead of a solid wall.
  void wallX(
    int c0,
    int r,
    int c1, {
    Set<int> openings = const {},
    String openPiece = 'wallDoorway',
    Set<int> windows = const {},
  }) {
    for (var c = c0; c < c1; c++) {
      final piece = openings.contains(c)
          ? openPiece
          : windows.contains(c)
          ? 'wallWindow'
          : 'wall';
      add(piece, c.toDouble(), -r.toDouble(), scale: _wallScale);
    }
  }

  /// A wall running along z at the edge `x = c`, covering rows `[r0, r1)`.
  void wallZ(
    int c,
    int r0,
    int r1, {
    Set<int> openings = const {},
    String openPiece = 'wallDoorway',
    Set<int> windows = const {},
  }) {
    for (var r = r0; r < r1; r++) {
      final piece = openings.contains(r)
          ? openPiece
          : windows.contains(r)
          ? 'wallWindow'
          : 'wall';
      add(
        piece,
        c.toDouble(),
        -r.toDouble(),
        yaw: math.pi / 2,
        scale: _wallScale,
      );
    }
  }

  RoomLayout build(String id) => RoomLayout(
    id: id,
    placements: List.unmodifiable(_placements),
    pieces: _placements.map((p) => p.piece).toSet(),
  );
}
