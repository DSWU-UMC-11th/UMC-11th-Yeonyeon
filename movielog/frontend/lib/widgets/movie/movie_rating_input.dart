import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// 사용자가 직접 별점을 선택할 수 있는 입력용 위젯.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      allowHalfRating: false,
      ignoreGestures: !enabled,
      itemCount: 5,
      itemSize: 32,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      unratedColor: const Color(0xFFE3DFE7),
      itemBuilder: (context, index) =>
          const Icon(Icons.star, color: Color(0xFF6750A4)),
      onRatingUpdate: onChanged,
    );
  }
}
