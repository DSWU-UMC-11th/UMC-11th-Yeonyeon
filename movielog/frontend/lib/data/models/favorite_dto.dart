class FavoriteDto {
  const FavoriteDto({
    required this.favoriteId,
    required this.movieId,
    required this.createdAt,
  });
  final int favoriteId;
  final int movieId;
  final String createdAt;
  factory FavoriteDto.fromJson(Map<String, dynamic> json) => FavoriteDto(
    favoriteId: (json['favoriteId'] as num).toInt(),
    movieId: (json['movieId'] as num).toInt(),
    createdAt: json['createdAt'] as String? ?? '',
  );
}

class FavoriteResponseDto {
  const FavoriteResponseDto({
    required this.favoriteId,
    required this.movieId,
    required this.createdAt,
  });
  final int favoriteId;
  final int movieId;
  final String createdAt;
  factory FavoriteResponseDto.fromJson(Map<String, dynamic> json) =>
      FavoriteResponseDto(
        favoriteId: (json['favoriteId'] as num).toInt(),
        movieId: (json['movieId'] as num).toInt(),
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class FavoriteCheckDto {
  const FavoriteCheckDto({required this.movieId, required this.isFavorite});
  final int movieId;
  final bool isFavorite;
  factory FavoriteCheckDto.fromJson(
    Map<String, dynamic> json, {
    required int movieId,
  }) => FavoriteCheckDto(
    movieId: movieId,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
}
