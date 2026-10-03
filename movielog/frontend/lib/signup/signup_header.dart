import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('환영합니다!', style: AppTextStyles.bodyMedium.copyWith(fontSize: 15)),
        const SizedBox(height: 4),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
