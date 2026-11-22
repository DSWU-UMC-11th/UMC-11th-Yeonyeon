import 'favorite_dto.dart';
import 'tmdb_movie_dto.dart';

class FavoriteListItem {
  const FavoriteListItem({required this.favorite, this.movie});
  final FavoriteDto favorite;
  final TmdbMovieDto? movie;
}
