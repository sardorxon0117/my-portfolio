import 'package:flutter/material.dart';
import '../core/theme.dart';

class StarRating extends StatelessWidget {
  final double rating; // 0-5, supports fractional (rounds for display)
  final double size;
  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final rounded = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rounded ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: AppColors.accent,
        );
      }),
    );
  }
}

/// Interactive 1-5 star picker for the review form.
class StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const StarPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        return IconButton(
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            starIndex <= value ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.accent,
            size: 30,
          ),
        );
      }),
    );
  }
}
