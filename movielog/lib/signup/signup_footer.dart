import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            // onPressed가 null이면 버튼이 비활성화된다.
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.violet.withOpacity(0.35),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '가입하기',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
