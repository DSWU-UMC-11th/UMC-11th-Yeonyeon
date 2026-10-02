import './movie.dart';

/// 홈 · 목록 · 상세 화면이 모두 동일한 Mock Data를 참조합니다.
const List<Movie> movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '로맨스 • 드라마',
    year: 2024,
    runtimeMinutes: 124,
    rating: 4.8,
    synopsis:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. '
        '매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n'
        '과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의문을 열게 됩니다.'
        '하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n\n'
        '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요?'
        '눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.',
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    runtimeMinutes: 138,
    rating: 4.2,
    synopsis:
        '마지막 신호를 쫓아 우주의 끝까지 향하는 탐사대의 이야기. '
        '광활한 우주 공간과 인간의 고독을 담은 하드 SF 작품입니다.',
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2024,
    runtimeMinutes: 96,
    rating: 4.9,
    synopsis: '숲속에서 우연히 신비한 존재를 만난 소녀가 잃어버린 기억을 되찾아가는 따뜻한 모험담입니다.',
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    runtimeMinutes: 112,
    rating: 3.8,
    synopsis: '어느 날 밤, 도시에서 벌어진 의문의 사건을 쫓는 형사의 추격전을 그린 느와르 스릴러입니다.',
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    runtimeMinutes: 112,
    rating: 4.5,
    synopsis: ' ',
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
  ),
  Movie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    runtimeMinutes: 112,
    rating: 4.1,
    synopsis: ' ',
    posterAsset: 'assets/images/posters/tommorow_sun.png',
  ),
  Movie(
    id: 7,
    title: '마션레스큐',
    genre: '다큐멘터리',
    year: 2023,
    runtimeMinutes: 112,
    rating: 4.5,
    synopsis: ' ',
    posterAsset: 'assets/images/posters/poster_abyss_walker.png',
    popularRank: 1,
    popularityScore: 9.6,
  ),
  Movie(
    id: 8,
    title: '스파이 코드',
    genre: '애니메이션',
    year: 2023,
    runtimeMinutes: 112,
    rating: 4.4,
    synopsis: ' ',
    posterAsset: 'assets/images/posters/poster_spycode.jpg',
    popularRank: 2,
    popularityScore: 9.2,
  ),
  Movie(
    id: 9,
    title: '비오는 날의 그림자',
    genre: '드라마',
    year: 2023,
    runtimeMinutes: 108,
    rating: 4.3,
    synopsis: '비 내리는 도시에서 우연히 마주친 두 사람이 서로의 오래된 기억을 되짚어 가는 이야기입니다.',
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    popularRank: 3,
    popularityScore: 8.9,
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}

/// 장르 Chip 목록 (전체 포함)
const List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '다큐멘터리'];
