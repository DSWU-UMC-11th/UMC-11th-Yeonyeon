class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.runtimeMinutes,
    required this.rating,
    required this.synopsis,
    required this.posterAsset,
    this.popularRank,
    this.popularityScore,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final int runtimeMinutes;
  final double rating;
  final String synopsis;

  /// 실제 포스터 이미지 Asset 대신, 실습 편의를 위해 색상으로 포스터를 표현합니다.
  /// 실제 프로젝트에서는 posterAsset(String 경로)로 교체해서 사용하면 됩니다.
  final String posterAsset;
  final int? popularRank;
  final double? popularityScore;
}
