import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/mock_listings.dart';
import '../../widgets/editorial.dart';
import '../detail/detail_page.dart';

/// Deliberately flat and quiet: no 3D here, so the app reads as an app rather
/// than a permanent tech demo.
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = mockListings.take(3).toList();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AbodeSpace.gutter,
                AbodeSpace.md,
                AbodeSpace.gutter,
                AbodeSpace.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('3 homes'),
                  SizedBox(height: AbodeSpace.xs),
                  Text('Saved', style: AbodeType.headline),
                ],
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: saved.length,
          itemBuilder: (context, i) {
            final listing = saved[i];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetailPage(listing: listing),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AbodeSpace.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Hairline(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.title, style: AbodeType.title),
                                const SizedBox(height: 4),
                                Text(
                                  listing.addressLine,
                                  style: AbodeType.label,
                                ),
                                const SizedBox(height: 10),
                                MetaLine(
                                  parts: [
                                    '${listing.bedrooms} bed',
                                    '${listing.bathrooms} bath',
                                    '${listing.areaSqm} m²',
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AbodeSpace.md),
                          Text(
                            listing.formattedPrice,
                            style: AbodeType.title.copyWith(
                              fontFamily: AbodeType.display,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AbodeSpace.gutter),
            child: Hairline(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
