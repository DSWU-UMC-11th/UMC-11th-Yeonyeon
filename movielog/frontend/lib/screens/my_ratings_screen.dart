import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bar.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/tmdb_poster_image.dart';
import '../widgets/movie/rating_dialog.dart';
import '../widgets/movielog_button.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<MyRatingsViewModel>(
    builder: (context, vm, _) => PopScope(
      canPop: !vm.isDeletingSelected,
      child: Scaffold(
        backgroundColor: AppColors.warmWhite,
        appBar: const CommonAppBar(title: '내가 등록한 평점', centerTitle: true),
        body: Stack(
          children: [
            Column(
              children: [
                if (vm.status == MyRatingsLoadStatus.success || vm.editing)
                  _modeBar(context, vm),
                Expanded(child: _body(context, vm)),
                if (vm.refreshWarning != null || vm.message != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      vm.refreshWarning ?? vm.message!,
                      style: const TextStyle(color: AppColors.gray),
                    ),
                  ),
                if (vm.editing)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton(
                        onPressed: vm.selectedRatingIds.isEmpty
                            ? null
                            : () => _confirmBulkDelete(context, vm),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          '선택한 ${vm.selectedRatingIds.length}개 삭제',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (vm.isDeletingSelected)
              const ModalBarrier(dismissible: false, color: Colors.black38),
            if (vm.isDeletingSelected)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _modeBar(BuildContext context, MyRatingsViewModel vm) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
    child: Row(
      children: [
        if (vm.editing)
          Text(
            '${vm.selectedRatingIds.length}개 선택됨',
            style: const TextStyle(
              color: AppColors.violet,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          const Spacer(),
        const Spacer(),
        TextButton(
          onPressed: vm.editing ? vm.cancelEditing : vm.toggleEditing,
          child: Text(
            vm.editing ? '취소' : '편집',
            style: const TextStyle(
              color: AppColors.violet,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _body(BuildContext context, MyRatingsViewModel vm) {
    if (vm.status == MyRatingsLoadStatus.idle ||
        vm.status == MyRatingsLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.status == MyRatingsLoadStatus.empty) {
      return const Center(child: Text('등록한 평점이 없습니다.'));
    }
    if (vm.status == MyRatingsLoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.message ?? '평점을 불러오지 못했습니다.'),
            TextButton(onPressed: vm.load, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: vm.ratings.length,
      itemBuilder: (context, i) {
        final entry = vm.ratings[i];
        final id = entry.rating.ratingId;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDAD4E2), width: 2),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              if (vm.editing)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Checkbox(
                    value: vm.selectedRatingIds.contains(id),
                    onChanged: (_) => vm.toggleSelected(id),
                    activeColor: AppColors.violet,
                  ),
                ),
              if (!vm.editing)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: TmdbPosterImage(
                    posterPath: entry.movie?.posterPath,
                    width: 82,
                    height: 126,
                  ),
                ),
              if (!vm.editing) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vm.editing
                          ? '${entry.movie?.title ?? '영화 #${entry.rating.movieId}'} · 별점 ${entry.rating.score}'
                          : entry.movie?.title ?? '영화 #${entry.rating.movieId}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!vm.editing)
                      Text(
                        '별점 ${entry.rating.score} / 5',
                        style: const TextStyle(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (entry.rating.comment?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          entry.rating.comment!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.gray),
                        ),
                      ),
                  ],
                ),
              ),
              if (!vm.editing) const SizedBox(width: 12),
              if (!vm.editing)
                Column(
                  children: [
                    SizedBox(
                      width: 86,
                      height: 48,
                      child: TextButton(
                        onPressed: () => _edit(
                          context,
                          vm,
                          id,
                          entry.rating.score,
                          entry.rating.comment,
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1EAF8),
                          foregroundColor: AppColors.violet,
                        ),
                        child: const Text('수정'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 86,
                      height: 48,
                      child: TextButton(
                        onPressed: () => _deleteOne(context, vm, id),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF0EE),
                          foregroundColor: const Color(0xFFC62828),
                        ),
                        child: const Text('삭제'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(
    BuildContext context,
    MyRatingsViewModel vm,
    int id,
    int score,
    String? comment,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        initialScore: score,
        initialComment: comment,
        onSubmit: (newScore, newComment) =>
            vm.updateRating(ratingId: id, score: newScore, comment: newComment),
      ),
    );
    if (context.mounted && saved == true) {
      final text = vm.refreshWarning ?? vm.message ?? '평점을 수정했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _deleteOne(
    BuildContext context,
    MyRatingsViewModel vm,
    int id,
  ) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteRatingDialog(onConfirm: () => vm.deleteRating(id)),
    );
    if (context.mounted && deleted == true) {
      final text = vm.refreshWarning ?? vm.message ?? '평점을 삭제했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _confirmBulkDelete(
    BuildContext context,
    MyRatingsViewModel vm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('선택한 평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await vm.deleteSelectedRatings();
      if (context.mounted) {
        final text = vm.refreshWarning ?? vm.message ?? '선택한 평점을 삭제했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      }
    }
  }
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});
  final Future<void> Function() onConfirm;
  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isDeleting,
    child: AlertDialog(
      title: const Text('평점을 삭제할까요?'),
      content: const Text('삭제한 평점은 복구할 수 없습니다.'),
      actions: [
        MovieLogButton(
          label: '취소',
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
        ),
        MovieLogButton(
          label: '삭제',
          isLoading: _isDeleting,
          onPressed: _isDeleting ? null : _onConfirm,
        ),
      ],
    ),
  );

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }
}
