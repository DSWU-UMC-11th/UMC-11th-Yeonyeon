import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, required this.bio});

  final String name;
  final String bio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/profile/profile_movielog.jpg',
            width: 124,
            height: 124,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          name,
          textAlign: TextAlign.center,
          style: AppTextStyles.profileName,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Text(
            bio,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileBio,
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warmWhite,
            foregroundColor: AppColors.violet,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            side: const BorderSide(color: AppColors.violet),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('프로필 수정'),
        ),
      ],
    );
  }
}
