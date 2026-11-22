import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/load_phase.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/movie/movie_page_footer.dart';
import '../widgets/movie/tmdb_movie_card.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});
  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _controller = TextEditingController();
  String? _submitted;
  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    setState(() => _submitted = value);
    context.read<PagedMoviesViewModel>().loadInitial(
      searchQuery: value,
      sessionVersion: context.read<AuthViewModel>().sessionVersion,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('영화 검색')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '영화 제목을 검색하세요',
              suffixIcon: IconButton(
                onPressed: _submit,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        Expanded(
          child: Consumer<PagedMoviesViewModel>(
            builder: (context, vm, _) {
              if (_submitted == null) {
                return const Center(child: Text('검색어를 입력해 주세요.'));
              }
              if (vm.phase == LoadPhase.loading && vm.movies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.phase == LoadPhase.error && vm.movies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.message ?? '검색에 실패했습니다.'),
                      TextButton(
                        onPressed: _submit,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                );
              }
              if (vm.phase == LoadPhase.empty) {
                return const Center(child: Text('검색 결과가 없습니다.'));
              }
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: .64,
                          ),
                      itemCount: vm.movies.length,
                      itemBuilder: (_, i) => TmdbMovieCard(movie: vm.movies[i]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: MoviePageFooter(
                      loading: vm.loadingMore,
                      hasNext: vm.hasNextPage,
                      error: vm.loadingMore
                          ? null
                          : (vm.page > 0 ? vm.message : null),
                      onPressed: () => vm.loadNextPage(
                        sessionVersion: context
                            .read<AuthViewModel>()
                            .sessionVersion,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
