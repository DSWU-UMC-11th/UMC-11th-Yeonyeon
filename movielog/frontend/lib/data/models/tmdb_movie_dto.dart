class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.genreIds,
    this.genreNames = const [],
    this.runtimeMinutes,
    required this.voteAverage,
    required this.popularity,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final List<String> genreNames;
  final int? runtimeMinutes;
  final double voteAverage;
  final double popularity;

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      genreIds:
          (json['genre_ids'] as List<dynamic>? ??
                  (json['genres'] as List<dynamic>? ?? const [])
                      .whereType<Map<String, dynamic>>()
                      .map((genre) => genre['id'])
                      .whereType<num>()
                      .toList())
              .map((id) => (id as num).toInt())
              .toList(growable: false),
      genreNames: (json['genres'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((genre) => genre['name'])
          .whereType<String>()
          .toList(growable: false),
      runtimeMinutes: (json['runtime'] as num?)?.toInt(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
    );
  }
}
