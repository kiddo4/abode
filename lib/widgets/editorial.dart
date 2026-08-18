import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A hairline rule. Used instead of shadows or gradients to separate content.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: indent),
    child: const ColoredBox(
      color: AbodeColors.hairline,
      child: SizedBox(height: 1, width: double.infinity),
    ),
  );
}

/// Small letter-spaced section header.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AbodeType.eyebrow);
}

/// One row of the specification table: label left, value right, rule beneath.
class SpecRow extends StatelessWidget {
  const SpecRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(label, style: AbodeType.bodyText)),
              Text(
                value,
                style: AbodeType.title.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const Hairline(),
      ],
    );
  }
}

/// Compact "3 bed · 2 bath · 148 m²" metadata line.
class MetaLine extends StatelessWidget {
  const MetaLine({super.key, required this.parts, this.color});

  final List<String> parts;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      parts.join('  ·  '),
      style: AbodeType.label.copyWith(color: color ?? AbodeColors.inkSecondary),
    );
  }
}

/// The line a house stands on. Architectural drawings terminate a datum with
/// short ticks; without it the models float in the middle of a white card.
class GroundLine extends StatelessWidget {
  const GroundLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        _Tick(),
        Expanded(child: Hairline()),
        _Tick(),
      ],
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AbodeColors.hairline,
    child: SizedBox(width: 1, height: 7),
  );
}

/// Three measured cells divided by rules — the specification, set as a table
/// rather than run together into one grey sentence.
class SpecTable extends StatelessWidget {
  const SpecTable({super.key, required this.cells});

  /// Label/value pairs, in reading order.
  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Hairline(),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 11, bottom: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(cells[i].$1),
                        const SizedBox(height: 5),
                        Text(
                          cells[i].$2,
                          style: AbodeType.title.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i != cells.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: ColoredBox(
                      color: AbodeColors.hairline,
                      child: SizedBox(width: 1),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Vertical position marker for the feed: a stack of ticks with the current
/// one drawn long and in the accent.
class FeedIndicator extends StatelessWidget {
  const FeedIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: i == current ? 14 : 7,
              height: 1.5,
              color: i == current
                  ? AbodeColors.accent
                  : AbodeColors.hairline,
            ),
          ),
      ],
    );
  }
}
