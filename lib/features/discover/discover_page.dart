import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glint_engine/glint_engine.dart';

import '../../app/theme.dart';
import '../../data/listing.dart';
import '../../data/mock_listings.dart';
import '../../widgets/editorial.dart';
import '../detail/detail_page.dart';

/// The feed: one listing per page, each a live 3D house.
///
/// Only the settled page mounts a [Scene3D]. A list of simultaneously live GPU
/// viewports is the obvious way to build this and the wrong one — neighbours
/// render a quiet placeholder until they are the current page.
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late final PageController _controller;
  int _page = 0;
  final Set<String> _saved = {};

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                itemCount: mockListings.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => Padding(
                  // Bottom inset clears the floating glass tab bar.
                  padding: const EdgeInsets.fromLTRB(
                    AbodeSpace.md,
                    AbodeSpace.sm,
                    AbodeSpace.md,
                    100,
                  ),
                  child: _ListingCard(
                    listing: mockListings[i],
                    index: i,
                    live: i == _page,
                    saved: _saved.contains(mockListings[i].id),
                    onToggleSave: () => setState(() {
                      final id = mockListings[i].id;
                      _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
                    }),
                  ),
                ),
              ),
              Positioned(
                right: 9,
                top: 0,
                bottom: 100,
                child: Center(
                  child: FeedIndicator(
                    count: mockListings.length,
                    current: _page,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AbodeSpace.gutter,
          AbodeSpace.md,
          AbodeSpace.gutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Expanded(
                  child: Text('Discover', style: AbodeType.headline),
                ),
                Text(
                  '${(_page + 1).toString().padLeft(2, '0')} / '
                  '${mockListings.length.toString().padLeft(2, '0')}',
                  style: AbodeType.index,
                ),
              ],
            ),
            const SizedBox(height: AbodeSpace.sm),
            const Eyebrow('Lagos · for sale'),
            const SizedBox(height: AbodeSpace.md),
            const Hairline(),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatefulWidget {
  const _ListingCard({
    required this.listing,
    required this.index,
    required this.live,
    required this.saved,
    required this.onToggleSave,
  });

  final Listing listing;
  final int index;

  /// Whether this card owns the one live GPU viewport.
  final bool live;
  final bool saved;
  final VoidCallback onToggleSave;

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _showHint = true;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    // The viewport looks like an image until you drag it, so say so — once.
    _hintTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => DetailPage(listing: listing)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AbodeColors.surface,
          borderRadius: BorderRadius.circular(AbodeRadius.card),
          border: Border.all(color: AbodeColors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    (widget.index + 1).toString().padLeft(2, '0'),
                    style: AbodeType.index,
                  ),
                  const Spacer(),
                  _SaveButton(saved: widget.saved, onTap: widget.onToggleSave),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: widget.live
                          ? Scene3D(
                              children: [Node3D(model: listing.model)],
                              camera: OrbitCamera(
                                position: Vector3(
                                  0,
                                  0.9,
                                  listing.orbitDistance,
                                ),
                                target: const Vector3(0, 0.1, 0),
                                fieldOfView: 32,
                              ),
                              lights: const [
                                DirectionalLight(
                                  direction: Vector3(0.5, -1, -0.6),
                                  intensity: 0.9,
                                ),
                                EnvironmentLight(
                                  asset: 'assets/hdri/studio_small_09_1k.hdr',
                                ),
                              ],
                              backgroundColor: AbodeColors.viewport,
                              // Horizontal drags orbit, vertical drags keep
                              // paging the feed.
                              gestureMode: GlintGestureMode.scrollAware,
                              gpuFallback: const _CardPlaceholder(),
                            )
                          : const _CardPlaceholder(),
                    ),
                    if (widget.live)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 2,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _showHint ? 1 : 0,
                            duration: const Duration(milliseconds: 500),
                            child: const Center(child: _OrbitHint()),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const GroundLine(),
              const SizedBox(height: 16),
              Eyebrow(listing.addressLine),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: AbodeType.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AbodeSpace.sm),
                  Text(
                    listing.formattedPrice,
                    style: AbodeType.price.copyWith(fontSize: 22),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SpecTable(
                cells: [
                  ('Beds', '${listing.bedrooms}'),
                  ('Baths', '${listing.bathrooms}'),
                  ('Area', '${listing.areaSqm} m²'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saved, required this.onTap});

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: saved ? AbodeColors.accent : AbodeColors.hairline,
          ),
          color: saved ? AbodeColors.accent : Colors.transparent,
        ),
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 15,
          color: saved ? Colors.white : AbodeColors.inkTertiary,
        ),
      ),
    );
  }
}

/// Fades out after a beat — the viewport reads as a still image otherwise.
class _OrbitHint extends StatelessWidget {
  const _OrbitHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AbodeColors.canvas,
        borderRadius: BorderRadius.circular(AbodeRadius.chip),
        border: Border.all(color: AbodeColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.swipe_rounded,
            size: 13,
            color: AbodeColors.inkTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            'Drag to orbit',
            style: AbodeType.eyebrow.copyWith(letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

/// Shown for cards that are not the live viewport.
class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AbodeColors.viewport,
    child: Center(
      child: Icon(Icons.home_outlined, size: 28, color: AbodeColors.hairline),
    ),
  );
}
