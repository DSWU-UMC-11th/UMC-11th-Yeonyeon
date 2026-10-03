import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TermsAgreementCheckbox extends StatelessWidget {
  const TermsAgreementCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.violet,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        // 긴 문구가 들어와도 overflow 되지 않도록 Flexible 사용
        Flexible(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              '필수 약관에 동의합니다',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
