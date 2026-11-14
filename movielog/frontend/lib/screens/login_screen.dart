import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  AuthViewModel? _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthViewModel>();
    if (_auth == auth) return;
    _auth?.removeListener(_onAuthChanged);
    _auth = auth..addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    final auth = _auth;
    if (!mounted || auth == null || !auth.sessionExpired) return;
    auth.consumeSessionExpired();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 세션이 만료되었습니다. 다시 로그인해 주세요.')),
        );
      }
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthViewModel>().login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '로그인',
          style: TextStyle(color: AppColors.violet, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 70),
                    const Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.movie_creation_rounded, size: 58, color: AppColors.black),
                          Padding(
                            padding: EdgeInsets.only(top: 9),
                            child: Icon(Icons.play_arrow_rounded, size: 22, color: AppColors.violet),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'MovieLog에 로그인',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.black, fontSize: 23, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 30),
                    const _LoginFieldLabel('이메일'),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      decoration: _inputDecoration(),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? '이메일을 입력해 주세요.'
                          : null,
                    ),
                    const SizedBox(height: 26),
                    const _LoginFieldLabel('비밀번호'),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _login(),
                      decoration: _inputDecoration(),
                      validator: (value) => value == null || value.isEmpty
                          ? '비밀번호를 입력해 주세요.'
                          : null,
                    ),
                    if (auth.message != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        auth.message!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 100),
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: auth.status == AuthStatus.authenticating ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: auth.status == AuthStatus.authenticating
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : const Text('로그인'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('계정이 없나요?', style: TextStyle(color: AppColors.gray, fontSize: 14)),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.violet,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('회원가입'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFDDD8E2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFDDD8E2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: AppColors.violet, width: 1.4),
    ),
  );
}

class _LoginFieldLabel extends StatelessWidget {
  const _LoginFieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: AppColors.statLabelGray, fontSize: 13),
  );
}
