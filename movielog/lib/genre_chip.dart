import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTextStyles.chipLabel),
      backgroundColor: AppColors.lavender,
      side: const BorderSide(color: Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
    );
  }
}
