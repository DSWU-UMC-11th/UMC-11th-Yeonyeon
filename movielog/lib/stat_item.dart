import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: 114,
      height: 86,
      decoration: BoxDecoration(
        color: Color(0xFFF5F3F0),
        border: Border.all(color: Color(0xFFE9DDFF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF494551),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
