import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/tmdb_client.dart';
import '../core/network/movie_log_client.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/token_storage.dart';
import '../view_models/auth_view_model.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../view_models/learning_member_session.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureTokenStorage();
    final publicClient = createMovieLogClient();
    final authClient = createAuthenticatedMovieLogClient(storage);
    final auth = AuthViewModel(AuthApiService(publicClient, authClient), storage)..initialize();
    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<SignUpService>(
          create: (_) => SignUpService(publicClient),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(publicClient, authClient),
        ),
        ChangeNotifierProvider<AuthViewModel>.value(value: auth),
        ChangeNotifierProvider<LearningMemberSession>(create: (_) => LearningMemberSession()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.create(auth),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: const ClampingScrollPhysics(),
          overscroll: false,
        ),
      ),
    );
  }
}
