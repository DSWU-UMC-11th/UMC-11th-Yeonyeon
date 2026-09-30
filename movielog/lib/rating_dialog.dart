import 'package:flutter/material.dart';

import 'movie_rating_input.dart';

/// showDialog(context: ..., builder: ...)로 표시되는 커스텀 Dialog.
/// Navigator.pop(context, rating)으로 선택한 값을 호출부에 반환합니다.
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, this.initialRating = 0});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double rating = widget.initialRating;
  int _selectionResetKey = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFAF9F5),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '영화는 어떠셨나요?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              MovieRatingInput(
                key: ValueKey(_selectionResetKey),
                rating: rating,
                onChanged: (value) {
                  setState(() => rating = value);
                },
              ),
              if (widget.initialRating > 0) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    rating = 0;
                    _selectionResetKey++;
                  }),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6750A4),
                  ),
                  child: const Text(
                    '다시 선택하기',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ] else
                const SizedBox(height: 20),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: rating == 0
                      ? null
                      : () => Navigator.of(context).pop(rating),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFB8AACF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
