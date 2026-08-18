import 'package:flutter/material.dart';
import 'package:glint_engine/glint_engine.dart';

import '../../app/theme.dart';
import '../../data/listing.dart';
import '../../widgets/editorial.dart';
import '../interior/interior_page.dart';

/// A listing viewed in full: orbit the exterior, read the specs, step inside.
class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.listing});

  final Listing listing;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int? _selectedHotspot;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return Scaffold(
      backgroundColor: AbodeColors.canvas,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _viewport(listing)),
              SliverToBoxAdapter(child: _body(listing)),
            ],
          ),
          _backButton(context),
          _stepInside(context, listing),
        ],
      ),
    );
  }

  Widget _viewport(Listing listing) {
    return SizedBox(
      height: 460,
      child: Scene3D(
        children: [Node3D(model: listing.model)],
        camera: OrbitCamera(
          position: Vector3(0, 1.1, listing.orbitDistance * 1.02),
          target: const Vector3(0, 0.1, 0),
          fieldOfView: 34,
        ),
        lights: const [
          DirectionalLight(direction: Vector3(0.5, -1, -0.6), intensity: 0.9),
          EnvironmentLight(asset: 'assets/hdri/studio_small_09_1k.hdr'),
        ],
        backgroundColor: AbodeColors.viewport,
        // Inside a scrollable, so vertical drags must keep scrolling the page
        // while horizontal drags orbit the model.
        gestureMode: GlintGestureMode.scrollAware,
        labels: [
          for (var i = 0; i < listing.hotspots.length; i++)
            Label3D(
              anchor: listing.hotspots[i].anchor,
              occlusion: Label3DOcclusion.fade,
              child: _Hotspot(
                hotspot: listing.hotspots[i],
                expanded: _selectedHotspot == i,
                onTap: () => setState(
                  () => _selectedHotspot = _selectedHotspot == i ? null : i,
                ),
              ),
            ),
        ],
        gpuFallback: const _GpuFallback(),
      ),
    );
  }

  Widget _body(Listing listing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AbodeSpace.gutter,
        AbodeSpace.sm,
        AbodeSpace.gutter,
        140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('For sale'),
          const SizedBox(height: AbodeSpace.sm),
          Text(listing.title, style: AbodeType.headline),
          const SizedBox(height: AbodeSpace.xs),
          Text(listing.addressLine, style: AbodeType.bodyText),
          const SizedBox(height: AbodeSpace.lg),
          Text(listing.formattedPrice, style: AbodeType.price),
          const SizedBox(height: AbodeSpace.lg),
          const Hairline(),
          const SizedBox(height: AbodeSpace.lg),
          Text(listing.summary, style: AbodeType.bodyText),
          const SizedBox(height: AbodeSpace.xl),
          const Eyebrow('Specification'),
          const SizedBox(height: AbodeSpace.sm),
          const Hairline(),
          SpecRow(label: 'Bedrooms', value: '${listing.bedrooms}'),
          SpecRow(label: 'Bathrooms', value: '${listing.bathrooms}'),
          SpecRow(label: 'Internal area', value: '${listing.areaSqm} m²'),
          SpecRow(label: 'Year built', value: '${listing.yearBuilt}'),
          SpecRow(
            label: 'Price per m²',
            value: '\$${(listing.priceUsd / listing.areaSqm).round()}',
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AbodeSpace.md),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AbodeColors.surface,
              border: Border.all(color: AbodeColors.hairline),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 19,
              color: AbodeColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepInside(BuildContext context, Listing listing) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // Solid footer so the spec table does not read through the CTA.
        decoration: const BoxDecoration(
          color: AbodeColors.canvas,
          border: Border(top: BorderSide(color: AbodeColors.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AbodeSpace.gutter,
              AbodeSpace.md,
              AbodeSpace.gutter,
              AbodeSpace.md,
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InteriorPage(listing: listing),
                ),
              ),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: AbodeColors.ink,
                  borderRadius: BorderRadius.circular(AbodeRadius.chip),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.open_in_full_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: AbodeSpace.sm),
                    Text(
                      'Step inside',
                      style: AbodeType.title.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An anchored marker on the model. Collapsed it is a dot; tapped it expands
/// into a label without moving the anchor point.
class _Hotspot extends StatelessWidget {
  const _Hotspot({
    required this.hotspot,
    required this.expanded,
    required this.onTap,
  });

  final ExteriorHotspot hotspot;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        child: expanded
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AbodeColors.ink,
                  borderRadius: BorderRadius.circular(AbodeRadius.chip),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotspot.label,
                      style: AbodeType.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      hotspot.detail,
                      style: AbodeType.label.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AbodeColors.surface,
                  border: Border.all(color: AbodeColors.ink, width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AbodeColors.accent,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _GpuFallback extends StatelessWidget {
  const _GpuFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AbodeColors.canvas,
    child: Center(
      child: Text(
        'Flutter GPU is unavailable on this device.',
        style: AbodeType.bodyText,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
