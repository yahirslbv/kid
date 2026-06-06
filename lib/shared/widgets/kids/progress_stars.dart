import 'package:flutter/material.dart';

class ProgressStars extends StatelessWidget {
  final int earned;
  final int total;
  final double size;

  const ProgressStars({
    super.key,
    required this.earned,
    this.total = 5,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = total < 0 ? 0 : total;
    final safeEarned = earned.clamp(0, safeTotal);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(safeTotal, (index) {
        final isFilled = index < safeEarned;
        return Padding(
          padding: EdgeInsets.only(right: index == safeTotal - 1 ? 0 : 3),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFilled ? const Color(0xFFFFB703) : const Color(0xFFB8C5D6),
            size: size,
          ),
        );
      }),
    );
  }
}
