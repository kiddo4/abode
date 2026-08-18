import 'package:glint_engine/glint_engine.dart';

import 'interior/layouts.dart';
import 'listing.dart';

const _a = 'assets/models/exterior/building-type-a.glb';
const _d = 'assets/models/exterior/building-type-d.glb';
const _t = 'assets/models/exterior/building-type-t.glb';

/// Anchors live in each model's own coordinate space. The exteriors are
/// origin-centred in x/z and sit on y = 0, roughly 1.3 × 1.0 units in plan.
final List<Listing> mockListings = [
  Listing(
    id: 'gable-house',
    title: 'The Gable House',
    neighbourhood: 'Rosebank',
    city: 'Lagos',
    priceUsd: 412000,
    bedrooms: 2,
    bathrooms: 1,
    areaSqm: 94,
    yearBuilt: 2019,
    summary:
        'A compact two-bedroom with a deep pitched roof and full-height glazing '
        'to the street. The living and kitchen share one uninterrupted volume.',
    exteriorModel: _a,
    interiorLayoutId: 'courtyard-flat',
    waypoints: courtyardFlatWaypoints,
    hotspots: const [
      ExteriorHotspot(
        anchor: Vector3(0, 0.96, 0.12),
        label: 'Pitched roof',
        detail: 'Standing-seam metal, 38° pitch',
      ),
      ExteriorHotspot(
        anchor: Vector3(0.3, 0.24, 0.66),
        label: 'Entrance',
        detail: 'Recessed porch, north facing',
      ),
      ExteriorHotspot(
        anchor: Vector3(-0.68, 0.1, 0.55),
        label: 'Side garden',
        detail: '40 m² planted strip',
      ),
    ],
  ),
  Listing(
    id: 'tower-house',
    title: 'Tower House',
    neighbourhood: 'Ikoyi',
    city: 'Lagos',
    priceUsd: 780000,
    bedrooms: 4,
    bathrooms: 3,
    areaSqm: 186,
    yearBuilt: 2022,
    summary:
        'Three storeys stacked over a garage, with a corner stair tower that '
        'lifts the main bedroom above the tree line.',
    exteriorModel: _d,
    interiorLayoutId: 'courtyard-flat',
    waypoints: courtyardFlatWaypoints,
    hotspots: const [
      ExteriorHotspot(
        anchor: Vector3(0, 1.38, 0.14),
        label: 'Stair tower',
        detail: 'Top-lit, full height',
      ),
      ExteriorHotspot(
        anchor: Vector3(0.44, 0.27, 0.66),
        label: 'Double garage',
        detail: 'Direct internal access',
      ),
    ],
  ),
  Listing(
    id: 'courtyard-house',
    title: 'Courtyard House',
    neighbourhood: 'Lekki Phase 1',
    city: 'Lagos',
    priceUsd: 655000,
    bedrooms: 3,
    bathrooms: 2,
    areaSqm: 148,
    yearBuilt: 2021,
    summary:
        'Rooms wrap a planted courtyard, so every space is cross-ventilated and '
        'lit from two sides. Deep eaves keep the afternoon sun off the glass.',
    exteriorModel: _t,
    interiorLayoutId: 'courtyard-flat',
    waypoints: courtyardFlatWaypoints,
    hotspots: const [
      ExteriorHotspot(
        anchor: Vector3(0, 1.3, 0.16),
        label: 'Deep eaves',
        detail: '900mm overhang, all elevations',
      ),
      ExteriorHotspot(
        anchor: Vector3(0.32, 0.22, 0.86),
        label: 'Courtyard',
        detail: 'Open to sky, 6 × 4 m',
      ),
    ],
  ),
  Listing(
    id: 'garden-rooms',
    title: 'Garden Rooms',
    neighbourhood: 'Yaba',
    city: 'Lagos',
    priceUsd: 298000,
    bedrooms: 2,
    bathrooms: 1,
    areaSqm: 88,
    yearBuilt: 2018,
    summary:
        'A modest plan opened up at the rear, where a glazed room steps down '
        'into the garden.',
    exteriorModel: _a,
    interiorLayoutId: 'courtyard-flat',
    waypoints: courtyardFlatWaypoints,
    hotspots: const [
      ExteriorHotspot(
        anchor: Vector3(0.3, 0.24, 0.66),
        label: 'Entrance',
        detail: 'Sheltered, west facing',
      ),
    ],
  ),
  Listing(
    id: 'corner-villa',
    title: 'Corner Villa',
    neighbourhood: 'Victoria Island',
    city: 'Lagos',
    priceUsd: 1240000,
    bedrooms: 5,
    bathrooms: 4,
    areaSqm: 265,
    yearBuilt: 2023,
    summary:
        'A corner plot handled as two wings around a shaded terrace, with the '
        'principal rooms turned away from the road.',
    exteriorModel: _d,
    interiorLayoutId: 'courtyard-flat',
    waypoints: courtyardFlatWaypoints,
    hotspots: const [
      ExteriorHotspot(
        anchor: Vector3(0, 1.38, 0.14),
        label: 'Roof terrace',
        detail: 'Shaded, 55 m²',
      ),
      ExteriorHotspot(
        anchor: Vector3(-0.9, 0.24, 0.55),
        label: 'West wing',
        detail: 'Guest suite, separate entry',
      ),
    ],
  ),
];
