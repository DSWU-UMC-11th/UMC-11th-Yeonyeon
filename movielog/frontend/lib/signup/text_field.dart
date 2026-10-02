import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 라벨 + 입력창을 한 덩어리로 묶은 재사용 위젯.
/// 디자인상 라벨이 InputDecoration의 labelText가 아니라
/// 입력창 "위"에 굵게 표시되므로 Column으로 직접 구성한다.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.showStateIcon = true,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool showStateIcon;

  static const _errorColor = Color(0xFFE53935);
  static const _errorFill = Color(0xFFFBDCDC);
  static const _normalFill = Color(0xFFFAF8F6);
  static const _borderColor = Color(0xFFE0DDE5);

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 입력값 기준으로 에러/정상 상태를 계산해 아이콘·배경색에 반영
    final text = controller.text;
    final errorText = validator?.call(text);
    final hasError = text.isNotEmpty && errorText != null;
    final isValid = text.isNotEmpty && errorText == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onChanged,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              nextFocusNode!.requestFocus();
            } else {
              onSubmitted?.call();
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: hasError ? _errorFill : _normalFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: !showStateIcon || text.isEmpty
                ? null
                : Icon(
                    hasError ? Icons.error_outline : Icons.check_circle,
                    color: hasError ? _errorColor : AppColors.violet,
                  ),
            enabledBorder: _border(_borderColor),
            focusedBorder: _border(AppColors.violet, width: 2),
            errorBorder: _border(_errorColor),
            focusedErrorBorder: _border(_errorColor, width: 2),
            errorStyle: const TextStyle(color: _errorColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
