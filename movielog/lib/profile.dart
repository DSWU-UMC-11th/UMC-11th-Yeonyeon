import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_theme.dart';
import 'stat_item.dart';
import 'app_bar.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필', style: TextStyle(color: AppColors.violet)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween, -> 전체 간격 조정 문제
            children: [
              Column(
                children: [
                  // const SizedBox(height: 32),
                  const CircleAvatar(
                    radius: 62,
                    backgroundImage: AssetImage(
                      'assets/images/profile/profile_movielog.jpg',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '무비러버',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Manrope',
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    child: Text(
                      // '좋아하는 영화를 기록하고 있어요',
                      '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmWhite,
                  foregroundColor: AppColors.violet,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  side: BorderSide(color: AppColors.violet),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('프로필 수정'),
              ),
              const SizedBox(height: 32),
              Container(
                // margin: const EdgeInsets.symmetric(horizontal: 16),
                // padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    StatItem(label: '본 영화', value: '342'),
                    SizedBox(width: 8),
                    StatItem(label: '평점', value: '4.2'),
                    SizedBox(width: 8),
                    StatItem(label: '즐겨찾기', value: '58'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Text(
                    '선호하는 장르',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              const SizedBox(height: 16),
              Container(
                // margin: const EdgeInsets.symmetric(horizontal: 16),
                // padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Chip(
                      label: const Text(
                        '드라마',
                        style: TextStyle(color: Color(0xFF4F378A)),
                      ),
                      backgroundColor: Color(0xFFE9DDFF),
                      side: BorderSide(color: Colors.transparent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text(
                        'SF',
                        style: TextStyle(color: Color(0xFF4F378A)),
                      ),
                      backgroundColor: Color(0xFFE9DDFF),
                      side: BorderSide(color: Colors.transparent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text(
                        '애니메이션',
                        style: TextStyle(color: Color(0xFF4F378A)),
                      ),
                      backgroundColor: Color(0xFFE9DDFF),
                      side: BorderSide(color: Colors.transparent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ],
                ),
              ),

              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(
              //     foregroundColor: Theme.of(context).colorScheme.primary,
              //   ),
              //   child: const Text('나중에 하기'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
