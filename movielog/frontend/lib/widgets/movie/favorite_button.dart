import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/favorite_detail_view_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});
  @override
  Widget build(BuildContext context) => Consumer<FavoriteDetailViewModel>(
    builder: (context, vm, _) {
      if (vm.loading || vm.submitting) {
        return const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      if (!vm.initialized) {
        return IconButton(
          tooltip: '즐겨찾기 상태 다시 조회',
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await context.read<FavoriteDetailViewModel>().load();
            if (!context.mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  vm.initialized
                      ? (vm.isFavorite
                            ? '즐겨찾기 상태를 확인했습니다.'
                            : '즐겨찾기에 등록되지 않았습니다.')
                      : (vm.error ?? '즐겨찾기 상태를 확인하지 못했습니다.'),
                ),
              ),
            );
          },
          icon: const Icon(Icons.sync_problem_outlined),
        );
      }
      return IconButton(
        tooltip: vm.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await context
              .read<FavoriteDetailViewModel>()
              .toggle();
          if (!context.mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? (vm.isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 해제했습니다.')
                    : (vm.error ?? '즐겨찾기를 변경하지 못했습니다.'),
              ),
            ),
          );
        },
        icon: Icon(vm.isFavorite ? Icons.bookmark : Icons.bookmark_border),
      );
    },
  );
}
