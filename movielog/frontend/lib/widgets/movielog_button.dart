import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MovieLogButton extends StatelessWidget {
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.labelStyle,
    this.disabledBackgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry padding;
  final TextStyle? labelStyle;
  final Color? disabledBackgroundColor;

  bool get _disabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 44,
    child: ElevatedButton(
      onPressed: _disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet,
        disabledBackgroundColor: disabledBackgroundColor ?? AppColors.gray,
        foregroundColor: AppColors.white,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Text(label, maxLines: 1, softWrap: false, style: labelStyle),
    ),
  );
}
