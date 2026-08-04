import 'package:flutter/material.dart';
import '../core/theme.dart';

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String heading;
  final bool center;
  const SectionHeading({super.key, required this.eyebrow, required this.heading, this.center = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          heading,
          style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 26),
        ),
      ],
    );
  }
}
