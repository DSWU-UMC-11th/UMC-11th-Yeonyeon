import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/profile/genre_chip.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/stat_item.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          '내 프로필',
          style: TextStyle(
            color: AppColors.violet,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.violet, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        children: [
          ProfileHeader(
            name: auth.member?.nickname ?? '내 프로필',
            email: auth.member?.email ?? '',
            onEdit: () => context.push('/my/profile/edit'),
          ),
          if (auth.memberStatus == MemberLoadStatus.error)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: auth.loadMember,
                child: const Text('내 정보를 불러오지 못했습니다. 다시 시도'),
              ),
            ),
          const SizedBox(height: 32),
          const Row(
            children: [
              Expanded(child: StatItem(label: '본 영화', value: '342')),
              SizedBox(width: 8),
              Expanded(child: StatItem(label: '평점', value: '4.2')),
              SizedBox(width: 8),
              Expanded(child: StatItem(label: '즐겨찾기', value: '58')),
            ],
          ),
          const SizedBox(height: 24),
          Material(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push('/my/ratings'),
              child: Container(
                height: 66,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ratingEntryBorder, width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '내가 등록한 평점',
                        style: TextStyle(color: AppColors.black, fontSize: 16),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.violet, size: 30),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '선호하는 장르',
            style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              GenreChip(label: '드라마'),
              GenreChip(label: 'SF'),
              GenreChip(label: '애니메이션'),
            ],
          ),
        ],
      ),
    );
  }
}
