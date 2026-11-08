import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/profile/profile_header.dart';
import '../widgets/profile/genre_chip.dart';
import '../widgets/profile/stat_item.dart';
import '../app_bar.dart';
import '../theme/app_colors.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween, -> 전체 간격 조정 문제
            children: [
              // const SizedBox(height: 32),
              ProfileHeader(
                name: '무비러버',
                bio: '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StatItem(label: '본 영화', value: '342'),
                    SizedBox(width: 8),
                    StatItem(label: '평점', value: '4.2'),
                    SizedBox(width: 8),
                    StatItem(label: '즐겨찾기', value: '58'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/my/ratings'),
                  child: Container(
                    height: 66,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.ratingEntryBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            '내가 등록한 평점',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.violet,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    '선호하는 장르',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GenreChip(label: '드라마'),
                  SizedBox(width: 8),
                  GenreChip(label: 'SF'),
                  SizedBox(width: 8),
                  GenreChip(label: '애니메이션'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
