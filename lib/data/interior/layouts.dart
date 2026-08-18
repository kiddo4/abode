import 'dart:math' as math;

import 'package:glint_engine/glint_engine.dart';

import '../listing.dart';
import 'layout.dart';

/// The authored interiors, keyed by [Listing.interiorLayoutId].
final Map<String, RoomLayout> interiorLayouts = {
  'courtyard-flat': _buildCourtyardFlat(),
};

/// Waypoints for `courtyard-flat`, in the same world space as its placements.
const courtyardFlatWaypoints = <RoomWaypoint>[
  // Opens on an angled dollhouse view of the whole plan — the kit has no
  // ceilings of its own, and the ones added in _buildCourtyardFlat are dropped
  // for this view, so it reads as a floor plan you can then drop into.
  //
  // Deliberately not straight down: a view direction parallel to the (0,1,0)
  // up vector makes the camera basis degenerate. The distance is set by the
  // *horizontal* fit — in a portrait viewport the horizontal field of view is
  // roughly half the vertical one, so a 7-wide plan needs far more pull-back
  // than the vertical extent alone suggests.
  RoomWaypoint(
    name: 'Plan',
    eye: Vector3(3.5, 12, 8),
    focus: Vector3(3.5, 0.3, -2.2),
  ),
  // Focus heights sit just under eye level so the gaze reads as level; aiming
  // at the floor tipped every frame down into the floorboards.
  //
  // Each eye sits at the far side of its room looking back across it, rather
  // than close to the wall it faces — standing 0.7 units from the television
  // filled the frame with a single cabinet. Positions are also checked against
  // the furniture footprints in _buildCourtyardFlat.
  RoomWaypoint(
    name: 'Living',
    eye: Vector3(2.9, PlanBuilder.eyeHeight, -2.7),
    focus: Vector3(1.6, 0.62, -0.45),
  ),
  RoomWaypoint(
    name: 'Kitchen',
    eye: Vector3(6.4, PlanBuilder.eyeHeight, -2.6),
    focus: Vector3(5.0, 0.64, -0.3),
  ),
  RoomWaypoint(
    name: 'Bedroom',
    eye: Vector3(3.4, PlanBuilder.eyeHeight, -3.4),
    focus: Vector3(1.5, 0.52, -4.3),
  ),
  RoomWaypoint(
    name: 'Bath',
    eye: Vector3(6.5, PlanBuilder.eyeHeight, -3.4),
    focus: Vector3(5.0, 0.54, -4.4),
  ),
];

/// A 7×5 plan: open-plan living and kitchen across the front, bedroom and
/// bathroom behind a dividing wall.
///
///   z=0   ┌───────────────┬───────────┐
///         │    Living     │  Kitchen  │
///   z=-3  ├──── door ─────┴─── door ──┤
///         │   Bedroom     │   Bath    │
///   z=-5  └───────────────┴───────────┘
///        x=0             x=4         x=7
RoomLayout _buildCourtyardFlat() {
  final plan = PlanBuilder()
    ..floor(0, 0, 7, 5)
    ..ceiling(0, 0, 7, 5)
    // Shell. Windows face the street (north) and the courtyard (south).
    ..wallX(0, 0, 7, windows: {2, 5})
    ..wallX(0, 5, 7, windows: {1, 4})
    ..wallZ(0, 0, 5, windows: {1})
    ..wallZ(7, 0, 5, windows: {3})
    // Front-to-back divider, with a doorway into each rear room.
    ..wallX(0, 3, 7, openings: {1, 5})
    // Bedroom / bath divider.
    ..wallZ(4, 3, 5, openings: {4});

  _livingRoom(plan);
  _kitchen(plan);
  _bedroom(plan);
  _bathroom(plan);

  // Ceiling lights, one per room, just under the wall top.
  const lampY = PlanBuilder.wallHeight - 0.25;
  plan
    ..addAt('lampSquareCeiling', 1.8, lampY, -1.5)
    ..addAt('lampSquareCeiling', 5.4, lampY, -1.5)
    ..addAt('lampSquareCeiling', 1.8, lampY, -4.0)
    ..addAt('lampSquareCeiling', 5.5, lampY, -4.0);

  return plan.build('courtyard-flat');
}

void _livingRoom(PlanBuilder plan) {
  plan
    // Media wall against the street elevation.
    ..add('cabinetTelevision', 1.2, -0.3)
    ..addAt('televisionModern', 1.6, 0.31, -0.42)
    ..add('bookcaseOpen', 3.3, -0.3)
    // Seating grouped on a rug, facing the television.
    ..add('rugRectangle', 0.7, -2.15)
    ..add('loungeSofaLong', 0.85, -2.45)
    ..add('loungeChair', 3.2, -2.1, yaw: -math.pi / 2)
    ..add('tableCoffee', 1.9, -1.55)
    ..add('lampRoundFloor', 0.3, -2.75)
    ..add('pottedPlant', 3.55, -2.8)
    ..addAt('books', 3.45, 0.42, -0.35);
}

void _kitchen(PlanBuilder plan) {
  const counterZ = -0.06;
  const upperY = 0.72;
  plan
    // Counter run along the street wall.
    ..add('kitchenCabinet', 4.15, counterZ)
    ..add('kitchenSink', 4.6, counterZ)
    ..add('kitchenStove', 5.05, counterZ)
    ..add('kitchenCabinet', 5.5, counterZ)
    ..add('kitchenFridge', 6.1, counterZ)
    ..addAt('kitchenCabinetUpper', 4.15, upperY, counterZ)
    ..addAt('kitchenCabinetUpper', 4.6, upperY, counterZ)
    ..addAt('kitchenCabinetUpper', 5.05, upperY, counterZ)
    ..addAt('kitchenCoffeeMachine', 5.6, 0.45, -0.2)
    // Dining.
    ..add('table', 4.6, -2.1)
    ..add('chair', 4.75, -1.55, yaw: math.pi)
    ..add('chair', 4.75, -2.35)
    ..add('chair', 5.6, -1.95, yaw: -math.pi / 2)
    ..addAt('plantSmall1', 5.0, 0.33, -1.9);
}

void _bedroom(PlanBuilder plan) {
  plan
    ..add('bedDouble', 0.9, -3.08)
    ..add('cabinetBedDrawer', 0.35, -3.3)
    ..add('cabinetBedDrawer', 2.75, -3.3)
    ..addAt('lampSquareTable', 2.8, 0.26, -3.3)
    ..add('rugRound', 2.6, -4.9)
    ..add('coatRackStanding', 3.5, -4.7)
    ..add('pottedPlant', 0.3, -4.85);
}

void _bathroom(PlanBuilder plan) {
  plan
    ..add('bathtub', 4.3, -3.15)
    ..add('toilet', 5.9, -4.95, yaw: math.pi)
    ..addAt('bathroomSink', 4.35, 0.5, -4.95, yaw: math.pi)
    ..addAt('bathroomMirror', 4.4, 0.78, -4.98, yaw: math.pi)
    ..add('rugDoormat', 5.4, -3.9);
}
