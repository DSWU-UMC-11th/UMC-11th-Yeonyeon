import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import './mock_movies.dart';
import './movie.dart';
import './rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double? _myRating;
  bool _isFavorite = false;

  Movie? get _movie => findMovieById(widget.movieId);

  Future<void> _openRatingDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => RatingDialog(initialRating: _myRating ?? 0),
    );

    if (result != null && mounted) {
      setState(() => _myRating = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('별점 ${result.toStringAsFixed(1)}점을 남겼습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('영화 정보를 찾을 수 없습니다.')),
      );
    }

    final tags = movie.genre
        .split(RegExp(r'[•/]'))
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
    if (movie.id == 1) tags.add('감동적인');
    final synopsisParagraphs = movie.synopsis
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 64,
            backgroundColor: const Color(0xFFFAF9F5),
            foregroundColor: const Color(0xFF49454F),
            automaticallyImplyLeading: false,
            leading: IconButton(
              tooltip: '뒤로',
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6750A4)),
            ),
            title: const Text(
              'Cinema Archive',
              style: TextStyle(
                color: Color(0xFF6750A4),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                tooltip: '공유',
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('${movie.title} 공유'))),
                icon: const Icon(Icons.share_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Image.asset(
              movie.posterAsset,
              fit: BoxFit.cover,
              height: 585,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${movie.year} · ${movie.genre.replaceAll(' • ', '/')} · ${movie.runtimeMinutes}분',
                    style: const TextStyle(
                      color: Color(0xFF625D68),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating.clamp(0.0, 5.0).toDouble(),
                        itemCount: 5,
                        itemSize: 18,
                        itemPadding: const EdgeInsets.only(right: 1),
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Color(0xFF6750A4)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${movie.rating.toStringAsFixed(1)}  (1,245)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9E7E4),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xFF494551),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, color: Color(0xFFD8D2DC)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시놉시스',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 330,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var index = 0;
                            index < synopsisParagraphs.length;
                            index++) ...[
                          if (index > 0) const SizedBox(height: 26),
                          Text(
                            synopsisParagraphs[index].trim(),
                            style: const TextStyle(
                              color: Color(0xFF494551),
                              fontSize: 16,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_myRating != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '내가 남긴 평점: ${_myRating!.toStringAsFixed(1)}점',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F5),
            border: Border(top: BorderSide(color: Color(0xFFD8D2DC))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    size: 19,
                  ),
                  label: Text(_isFavorite ? '즐겨찾기 완료' : '즐겨찾기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6750A4),
                    side: const BorderSide(color: Color(0xFF6750A4)),
                    minimumSize: const Size(0, 48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openRatingDialog,
                  icon: const Icon(Icons.rate_review_outlined, size: 19),
                  label: const Text('평점 남기기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
