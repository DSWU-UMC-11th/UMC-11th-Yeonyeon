import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/load_phase.dart';
import '../view_models/favorites_view_model.dart';
import '../widgets/movie/tmdb_movie_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<FavoritesViewModel>();
    if (vm.phase == LoadPhase.initial) vm.refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('내 즐겨찾기')),
    body: Consumer<FavoritesViewModel>(
      builder: (context, vm, _) {
        if (vm.phase == LoadPhase.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.phase == LoadPhase.error) {
          return _state(vm.message ?? '즐겨찾기를 불러오지 못했습니다.', () => vm.refresh());
        }
        if (vm.phase == LoadPhase.empty) {
          return const Center(child: Text('등록한 즐겨찾기가 없습니다.'));
        }
        return RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (vm.hasMovieFailures)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '일부 영화 정보를 불러오지 못했습니다. 해당 항목은 placeholder로 표시됩니다.',
                  ),
                ),
              for (final item in vm.items)
                if (item.movie != null)
                  SizedBox(
                    height: 290,
                    child: TmdbMovieCard(
                      movie: item.movie!,
                      onReturn: vm.refresh,
                    ),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.movie_outlined),
                    title: Text('영화 #${item.favorite.movieId}'),
                    subtitle: const Text('영화 정보를 불러오지 못했습니다.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await context.push('/movies/${item.favorite.movieId}');
                      await vm.refresh();
                    },
                  ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _state(String text, VoidCallback retry) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(text),
      const SizedBox(height: 12),
      FilledButton(onPressed: retry, child: const Text('다시 시도')),
    ],
  ),
);
