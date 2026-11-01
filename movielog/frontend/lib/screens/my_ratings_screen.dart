import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bar.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/tmdb_poster_image.dart';
import '../widgets/movielog_button.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CommonAppBar(title: '내가 등록한 평점', centerTitle: true),
    body: Consumer<MyRatingsViewModel>(
      builder: (context, vm, _) {
        switch (vm.status) {
          case MyRatingsLoadStatus.idle:
          case MyRatingsLoadStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case MyRatingsLoadStatus.empty:
            return const Center(child: Text('등록한 평점이 없습니다.'));
          case MyRatingsLoadStatus.error:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.message ?? '평점을 불러오지 못했습니다.'),
                  const SizedBox(height: 12),
                  MovieLogButton(
                    label: '다시 시도',
                    width: 120,
                    onPressed: vm.load,
                  ),
                ],
              ),
            );
          case MyRatingsLoadStatus.success:
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (vm.message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      vm.message!,
                      style: const TextStyle(color: AppColors.gray),
                    ),
                  ),
                for (final entry in vm.ratings)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TmdbPosterImage(
                              posterPath: entry.movie?.posterPath,
                              width: 82,
                              height: 120,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.movie?.title ??
                                      '영화 정보 없음 (ID: ${entry.rating.movieId})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${entry.rating.score} / 5'),
                                  ],
                                ),
                                if (entry.rating.comment != null) ...[
                                  const SizedBox(height: 8),
                                  Text(entry.rating.comment!),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  '등록일 ${entry.rating.createdAt.toLocal().toString().split(' ').first}',
                                  style: const TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
        }
      },
    ),
  );
}
