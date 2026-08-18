import 'package:glint_engine/glint_engine.dart';

/// A hotspot pinned to a point on the exterior model.
///
/// [anchor] is in the model's own coordinate space — the same space
/// [GlintRayHit.position] reports, so anchors can be authored by tapping.
class ExteriorHotspot {
  const ExteriorHotspot({
    required this.anchor,
    required this.label,
    required this.detail,
  });

  final Vector3 anchor;
  final String label;
  final String detail;
}

/// One room the interior walkthrough can travel to.
class RoomWaypoint {
  const RoomWaypoint({
    required this.name,
    required this.eye,
    required this.focus,
  });

  final String name;

  /// Camera position at standing eye height, in world units.
  final Vector3 eye;

  /// What the camera looks at on arrival.
  final Vector3 focus;
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.neighbourhood,
    required this.city,
    required this.priceUsd,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqm,
    required this.yearBuilt,
    required this.summary,
    required this.exteriorModel,
    required this.hotspots,
    required this.interiorLayoutId,
    required this.waypoints,
    this.orbitDistance = 7.0,
  });

  final String id;
  final String title;
  final String neighbourhood;
  final String city;
  final int priceUsd;
  final int bedrooms;
  final int bathrooms;
  final int areaSqm;
  final int yearBuilt;
  final String summary;

  /// Asset key of the exterior GLB.
  final String exteriorModel;
  final List<ExteriorHotspot> hotspots;

  /// Key into the interior layout catalogue.
  final String interiorLayoutId;
  final List<RoomWaypoint> waypoints;

  /// Orbit camera distance. Glint normalises each model's scale on load, so
  /// this is in normalised units and is roughly comparable across models.
  final double orbitDistance;

  Model get model => Model.asset(exteriorModel);

  /// "$1,240,000" — grouped manually to avoid an intl dependency.
  String get formattedPrice {
    final digits = priceUsd.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '\$$buffer';
  }

  String get addressLine => '$neighbourhood · $city';
}
