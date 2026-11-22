import 'package:flutter/material.dart';

class MoviePageFooter extends StatelessWidget {
  const MoviePageFooter({
    super.key,
    required this.loading,
    required this.hasNext,
    required this.onPressed,
    this.error,
  });
  final bool loading, hasNext;
  final VoidCallback onPressed;
  final String? error;
  @override
  Widget build(BuildContext context) {
    if (!hasNext && !loading && error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (error != null) Text(error!),
          if (loading)
            const CircularProgressIndicator()
          else
            OutlinedButton(
              onPressed: onPressed,
              child: Text(error == null ? '더 보기' : '다시 시도'),
            ),
        ],
      ),
    );
  }
}
