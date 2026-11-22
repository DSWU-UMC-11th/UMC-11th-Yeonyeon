import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _nickname.text = context.read<AuthViewModel>().member?.nickname ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final saved = await context.read<AuthViewModel>().updateNickname(_nickname.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final email = auth.member?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '프로필 수정',
          style: TextStyle(color: AppColors.violet, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
            children: [
              const _FieldLabel('이메일 (변경할 수 없습니다)'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: email,
                readOnly: true,
                decoration: _fieldDecoration(filled: true),
                style: const TextStyle(color: AppColors.gray, fontSize: 14),
              ),
              const SizedBox(height: 38),
              const _FieldLabel('닉네임'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nickname,
                maxLength: 12,
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration(
                  counterText: '${_nickname.text.length} / 12',
                ),
                validator: (value) {
                  final length = value?.trim().length ?? 0;
                  if (length < 2 || length > 12) return '닉네임은 2~12자로 입력해 주세요.';
                  return null;
                },
              ),
              if (auth.message != null) ...[
                const SizedBox(height: 8),
                Text(
                  auth.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('다시 시도'),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('저장'),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({bool filled = false, String? counterText}) => InputDecoration(
    counterText: counterText,
    filled: filled,
    fillColor: const Color(0xFFF0EDF2),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFDDD8E2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: AppColors.violet, width: 1.4),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFDDD8E2)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: AppColors.statLabelGray, fontSize: 13),
  );
}
