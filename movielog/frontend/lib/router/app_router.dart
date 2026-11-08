import 'package:movielog/screens/my_page_screen.dart';
import 'package:movielog/screens/register_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/screens/MainScreen.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/view_models/signup_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              SignUpViewModel(context.read<SignUpService>()),
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['movieId'] ?? '');
          if (id == null || id < 1) return const Scaffold(body: Center(child: Text('영화 ID가 올바르지 않습니다.')));
          final extra = state.extra;
          return MovieDetailScreen(movieId: id, initialMovie: extra is TmdbMovieDto && extra.id == id ? extra : null);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) =>
                  MovieHomeViewModel(context.read<TmdbMovieService>())
                    ..loadPopular(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) =>
                  MovieListViewModel(context.read<TmdbMovieService>())
                    ..loadInitial(),
              child: const MovieListScreen(),
            ),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const Profile(),
            routes: [
              GoRoute(
                path: 'ratings',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final memberId = context.read<LearningMemberSession>().memberId;
                  if (memberId == null) return const _NeedsSignupScreen();
                  return ChangeNotifierProvider(
                    create: (context) => MyRatingsViewModel(context.read<RatingApiService>(), context.read<TmdbMovieService>(), memberId)..load(),
                    child: const MyRatingsScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;

    return 0;
  }
}

class _NeedsSignupScreen extends StatelessWidget {
  const _NeedsSignupScreen();
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('내가 등록한 평점')), body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('학습용 회원가입이 필요합니다.'), TextButton(onPressed: () => context.go('/register'), child: const Text('회원가입'))])));
}
