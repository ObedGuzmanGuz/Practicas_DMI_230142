import 'package:flutter/material.dart';

class MovieStarRating extends StatelessWidget {
  final double ratingOutOfTen;
  final double iconSize;
  final bool showNumericValue;

  const MovieStarRating({
    super.key,
    required this.ratingOutOfTen,
    this.iconSize = 18,
    this.showNumericValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final ratingOutOfFive = (ratingOutOfTen / 2).clamp(0.0, 5.0);
    final starColor = Colors.amber.shade700;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 1; index <= 5; index++)
          Icon(
            ratingOutOfFive >= index
                ? Icons.star_rounded
                : ratingOutOfFive >= index - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            color: starColor,
            size: iconSize,
          ),
        if (showNumericValue) ...[
          const SizedBox(width: 6),
          Text(
            '${ratingOutOfTen.toStringAsFixed(1)}/10',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: starColor,
                ),
          ),
        ],
      ],
    );
  }
}
