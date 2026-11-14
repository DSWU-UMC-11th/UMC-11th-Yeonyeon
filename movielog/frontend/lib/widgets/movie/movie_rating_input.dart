import 'package:flutter/material.dart';
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final selected = index < rating.round();
        return Semantics(
          button: true,
          label: '${index + 1}점${selected ? ' 선택됨' : ''}',
          child: InkResponse(
            onTap: enabled ? () => onChanged((index + 1).toDouble()) : null,
            radius: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                selected ? Icons.star_rounded : Icons.star_border_rounded,
                size: 36,
                color: const Color(0xFF6750A4),
              ),
            ),
          ),
        );
      }),
    );
  }
}
