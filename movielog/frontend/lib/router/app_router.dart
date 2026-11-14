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
import 'package:movielog/screens/login_screen.dart';
import 'package:movielog/screens/profile_edit_screen.dart';
import 'package:movielog/view_models/auth_view_model.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter create(AuthViewModel auth) => GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey,
    refreshListenable: auth,
    redirect: (context, state) => authRedirect(auth.status, state.uri.path),
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) =>
              SignUpViewModel(context.read<SignUpService>()),
          child: const SignUpScreen(),
        ),
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
            path: '/movies/:movieId',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['movieId'] ?? '');
              if (id == null || id < 1) {
                return const Scaffold(
                  body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
                );
              }
              final extra = state.extra;
              return MovieDetailScreen(
                movieId: id,
                initialMovie: extra is TmdbMovieDto && extra.id == id
                    ? extra
                    : null,
              );
            },
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const Profile(),
            routes: [
              GoRoute(path: 'profile/edit', parentNavigatorKey: rootNavigatorKey, builder: (context, state) => const ProfileEditScreen()),
              GoRoute(
                path: 'ratings',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final memberId = context.read<AuthViewModel>().member?.memberId;
                  if (memberId == null) return const _NeedsSignupScreen();
                  return ChangeNotifierProvider(
                    create: (context) => MyRatingsViewModel(context.read<RatingApiService>(), context.read<TmdbMovieService>(), context.read<AuthViewModel>(), memberId)..load(),
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

  static String? authRedirect(AuthStatus status, String location) {
    const publicPaths = {'/login', '/register'};
    final atStart = location == '/start';
    final atPublic = publicPaths.contains(location);
    return switch (status) {
      AuthStatus.initializing || AuthStatus.retryRequired => atStart ? null : '/start',
      AuthStatus.signedOut || AuthStatus.authenticating => atPublic ? null : '/login',
      AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
    };
  }

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
