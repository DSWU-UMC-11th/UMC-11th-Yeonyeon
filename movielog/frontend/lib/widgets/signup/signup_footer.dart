import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../movielog_button.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          disabledBackgroundColor: const Color(0xFFD8C8E8),
          onPressed: canSubmit ? onSubmit : null,
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '이미 계정이 있나요?',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onLoginTap,
              child: Text(
                '로그인',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.violet,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
