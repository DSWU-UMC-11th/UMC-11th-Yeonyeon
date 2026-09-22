import 'package:flutter/material.dart';

import '../app_bar.dart';
import './text_field.dart';
import './signup_footer.dart';
import './signup_header.dart';
import './agree_checkbox.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller / FocusNode는 build가 아니라 State에서 생성한다.
  //입력창 설정
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //focus할 때를 정의
  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // ---------- Validators ----------
  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return '이메일을 입력해주세요.';
    final regExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regExp.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return '비밀번호를 입력해주세요.';
    if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    return null;
  }

  // ---------- 버튼 활성화 조건 ----------
  bool get _canSubmit =>
      _validateNickname(_nicknameController.text) == null &&
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null &&
      _agreedToTerms;

  void _onSubmit() {
    // 버튼 활성화 조건과 별개로 제출 시 Form 전체를 다시 검증한다.
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nicknameController.text.trim()}님, 가입이 완료되었습니다!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: CommonAppBar(
        title: '회원가입',
        centerTitle: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 넓은 화면에서 Form이 과도하게 늘어나지 않도록 최대 너비만 제한
            final maxFormWidth = constraints.maxWidth >= 700
                ? 560.0
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    // 화면이 남으면 아래 영역을 밀어내고,
                    // 키보드가 올라오면 스크롤되어 Overflow가 나지 않는다.
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SignUpHeader(),
                          const SizedBox(height: 28),
                          LabeledTextField(
                            label: '닉네임',
                            hintText: '닉네임을 입력해주세요',
                            controller: _nicknameController,
                            focusNode: _nicknameFocusNode,
                            nextFocusNode: _emailFocusNode,
                            validator: _validateNickname,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          LabeledTextField(
                            label: '이메일',
                            hintText: '이메일 주소를 입력해주세요',
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            nextFocusNode: _passwordFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          LabeledTextField(
                            label: '비밀번호',
                            hintText: '비밀번호를 입력해주세요',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: () {
                              FocusScope.of(context).unfocus();
                              if (_canSubmit) _onSubmit();
                            },
                          ),
                          // 남은 공간을 차지해 체크박스/버튼을 하단에 붙인다.
                          const SizedBox(height: 32),
                          TermsAgreementCheckbox(
                            value: _agreedToTerms,
                            onChanged: (v) =>
                                setState(() => _agreedToTerms = v),
                          ),
                          const SizedBox(height: 16),
                          SignUpFooter(
                            canSubmit: _canSubmit,
                            onSubmit: _onSubmit,
                            onLoginTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
