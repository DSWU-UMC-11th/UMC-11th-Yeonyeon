import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/signup_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/signup/text_field.dart';
import 'package:provider/provider.dart';

void main() {
  group('Guided Practice A: 중복 확인', () {
    late _FakeMemberCheckService service;
    late SignUpViewModel viewModel;

    setUp(() {
      service = _FakeMemberCheckService();
      viewModel = SignUpViewModel(service);
    });

    tearDown(() => viewModel.dispose());

    testWidgets('빈 입력은 초기 상태이며 빨간색 테두리가 아니다', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledTextField(
              label: '닉네임',
              hintText: '닉네임',
              controller: controller,
              validator: (value) =>
                  value == null || value.isEmpty ? '필수 입력' : null,
            ),
          ),
        ),
      );

      final field = tester.widget<InputDecorator>(find.byType(InputDecorator));
      expect(viewModel.nicknameCheckStatus, CheckStatus.idle);
      expect(
        field.decoration.enabledBorder!.borderSide.color,
        isNot(const Color(0xFFE53935)),
      );
      controller.dispose();
    });

    test(
      '닉네임 checking, available, duplicated, edit reset, cached duplicate',
      () async {
        service.nicknameCompleter = Completer<bool>();
        viewModel.onNicknameChanged('사용가능');
        final pending = viewModel.checkNickname('사용가능');
        expect(viewModel.nicknameCheckStatus, CheckStatus.checking);
        service.nicknameCompleter!.complete(true);
        await pending;
        expect(viewModel.nicknameCheckStatus, CheckStatus.available);
        service.nicknameCompleter = null;

        service.nextNicknameAvailable = false;
        viewModel.onNicknameChanged('중복닉');
        await viewModel.checkNickname('중복닉');
        expect(viewModel.nicknameCheckStatus, CheckStatus.duplicated);
        expect(viewModel.nicknameErrorText, '이미 사용 중인 닉네임입니다.');

        viewModel.onNicknameChanged('새닉네임');
        expect(viewModel.nicknameCheckStatus, CheckStatus.idle);
        expect(viewModel.nicknameErrorText, isNull);
        viewModel.onNicknameChanged('중복닉');
        expect(viewModel.nicknameCheckStatus, CheckStatus.duplicated);
        expect(service.nicknameCalls, 2);
      },
    );

    test(
      '이메일 checking, available, duplicated, edit reset, cached duplicate',
      () async {
        service.emailCompleter = Completer<bool>();
        viewModel.onEmailChanged('available@example.com');
        final pending = viewModel.checkEmail('available@example.com');
        expect(viewModel.emailCheckStatus, CheckStatus.checking);
        service.emailCompleter!.complete(true);
        await pending;
        expect(viewModel.emailCheckStatus, CheckStatus.available);
        service.emailCompleter = null;

        service.nextEmailAvailable = false;
        viewModel.onEmailChanged('used@example.com');
        await viewModel.checkEmail('used@example.com');
        expect(viewModel.emailCheckStatus, CheckStatus.duplicated);
        expect(viewModel.emailErrorText, '이미 사용 중인 이메일입니다.');
        viewModel.onEmailChanged('new@example.com');
        expect(viewModel.emailCheckStatus, CheckStatus.idle);
        viewModel.onEmailChanged('used@example.com');
        expect(viewModel.emailCheckStatus, CheckStatus.duplicated);
        expect(service.emailCalls, 2);
      },
    );

    test('닉네임과 이메일 네트워크 실패는 error로 분리된다', () async {
      service.failNickname = true;
      viewModel.onNicknameChanged('실패닉네임');
      await viewModel.checkNickname('실패닉네임');
      expect(viewModel.nicknameCheckStatus, CheckStatus.error);
      expect(viewModel.nicknameErrorText, contains('실패'));

      service.failEmail = true;
      viewModel.onEmailChanged('fail@example.com');
      await viewModel.checkEmail('fail@example.com');
      expect(viewModel.emailCheckStatus, CheckStatus.error);
      expect(viewModel.emailErrorText, contains('실패'));
    });
  });

  testWidgets('MovieLogButton의 width, onPressed, isLoading을 확인한다', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieLogButton(
            label: '중복 확인',
            width: 180,
            onPressed: () => tapCount++,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MovieLogButton)).width, 180);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    await tester.tap(find.text('중복 확인'));
    expect(tapCount, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieLogButton(
            label: '중복 확인',
            width: 180,
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(tester.getSize(find.byType(MovieLogButton)).width, 180);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MovieLogButton(label: '중복 확인', onPressed: null)),
      ),
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });

  group('Guided Practice B / Required Mission: 내 평점 조회', () {
    late _FakeRatingApiService ratings;
    late _FakeTmdbMovieService movies;
    late MyRatingsViewModel viewModel;

    setUp(() {
      ratings = _FakeRatingApiService();
      movies = _FakeTmdbMovieService();
      viewModel = MyRatingsViewModel(ratings, movies, sampleMemberId);
    });

    tearDown(() => viewModel.dispose());

    test('요청 중 loading을 알리고 memberId 1의 목록과 영화 정보를 결합한다', () async {
      ratings.completer = Completer<List<RatingDto>>();
      final pending = viewModel.load();
      expect(viewModel.status, MyRatingsLoadStatus.loading);
      ratings.completer!.complete([
        _rating(5, 10, null),
        _rating(4, 10, '다시 볼 영화'),
        _rating(3, 20, '좋았어요'),
      ]);
      await pending;

      expect(ratings.requestedMemberId, 1);
      expect(viewModel.status, MyRatingsLoadStatus.success);
      expect(viewModel.ratings, hasLength(3));
      expect(viewModel.ratings.first.rating.comment, isNull);
      expect(viewModel.ratings.first.movie?.title, '영화 10');
      expect(movies.requestedIds, [10, 20]);
    });

    test('빈 목록은 empty, 오류는 error와 재시도 메시지를 제공한다', () async {
      ratings.response = [];
      await viewModel.load();
      expect(viewModel.status, MyRatingsLoadStatus.empty);

      ratings.fail = true;
      await viewModel.load();
      expect(viewModel.status, MyRatingsLoadStatus.error);
      expect(viewModel.message, contains('평점을 불러오지 못했습니다'));

      ratings.failureStatusCode = 400;
      await viewModel.load();
      expect(viewModel.message, 'memberId 형식을 다시 확인해 주세요.');
      ratings.failureStatusCode = 404;
      await viewModel.load();
      expect(viewModel.message, '존재하지 않는 회원입니다.');
    });

    testWidgets('화면에 loading, empty, error와 재시도 동작이 표시된다', (tester) async {
      ratings.completer = Completer<List<RatingDto>>();
      final pendingLoad = viewModel.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: const MaterialApp(home: MyRatingsScreen()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      ratings.completer!.complete([]);
      await pendingLoad;
      await tester.pump();
      expect(find.text('등록한 평점이 없습니다.'), findsOneWidget);

      ratings.completer = null;
      ratings.fail = true;
      final failedLoad = viewModel.load();
      await failedLoad;
      await tester.pump();
      expect(find.text('평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    test('TMDB 조회 실패 시 평점은 남기고 영화 placeholder 안내를 제공한다', () async {
      ratings.response = [_rating(5, 999, null)];
      movies.missingIds.add(999);
      await viewModel.load();

      expect(viewModel.status, MyRatingsLoadStatus.success);
      expect(viewModel.ratings.single.movie, isNull);
      expect(viewModel.message, contains('일부 영화 정보를 가져오지 못해'));
    });

    testWidgets('null comment는 숨기고 평점 카드와 제목을 표시한다', (tester) async {
      ratings.response = [_rating(5, 10, null)];
      await viewModel.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: viewModel,
          child: const MaterialApp(home: MyRatingsScreen()),
        ),
      );

      expect(find.text('내가 등록한 평점'), findsOneWidget);
      expect(find.text('영화 10'), findsOneWidget);
      expect(find.text('5 / 5'), findsOneWidget);
      expect(find.text('등록한 평점이 없습니다.'), findsNothing);
      expect(find.text('null'), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  });

  test(
    'TMDB detail DTO reads genres and runtime returned by detail endpoint',
    () {
      final movie = TmdbMovieDto.fromJson({
        'id': 10,
        'title': '상세 영화',
        'overview': '줄거리',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'release_date': '2024-01-01',
        'genres': [
          {'id': 18, 'name': '드라마'},
        ],
        'runtime': 123,
        'vote_average': 8.4,
        'popularity': 42.0,
      });

      expect(movie.genreIds, [18]);
      expect(movie.genreNames, ['드라마']);
      expect(movie.runtimeMinutes, 123);
    },
  );

  testWidgets('TMDB movie detail loads and renders the fetched movie', (
    tester,
  ) async {
    final service = _FakeTmdbMovieService()
      ..detailCompleter = Completer<TmdbMovieDto?>();
    await tester.pumpWidget(
      Provider<TmdbMovieService>.value(
        value: service,
        child: const MaterialApp(home: MovieDetailScreen(movieId: 10)),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    service.detailCompleter!.complete(_movie(10));
    await tester.pumpAndSettle();
    expect(find.text('영화 10'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('줄거리 10'), 250);
    expect(find.text('줄거리 10'), findsOneWidget);
    expect(find.textContaining('123분'), findsOneWidget);
    expect(find.text('드라마'), findsOneWidget);
    expect(find.text('평점 남기기'), findsOneWidget);
  });
}

RatingDto _rating(int id, int movieId, String? comment) => RatingDto(
  ratingId: id,
  movieId: movieId,
  score: 5,
  comment: comment,
  createdAt: DateTime.utc(2026, 10, 31),
);

class _FakeMemberCheckService extends MemberCheckService {
  _FakeMemberCheckService() : super(Dio());

  Completer<bool>? nicknameCompleter;
  Completer<bool>? emailCompleter;
  bool nextNicknameAvailable = true;
  bool nextEmailAvailable = true;
  bool failNickname = false;
  bool failEmail = false;
  int nicknameCalls = 0;
  int emailCalls = 0;

  @override
  Future<bool> checkNickname(String nickname) async {
    nicknameCalls++;
    if (failNickname) throw DioException(requestOptions: RequestOptions());
    return nicknameCompleter?.future ?? nextNicknameAvailable;
  }

  @override
  Future<bool> checkEmail(String email) async {
    emailCalls++;
    if (failEmail) throw DioException(requestOptions: RequestOptions());
    return emailCompleter?.future ?? nextEmailAvailable;
  }
}

class _FakeRatingApiService extends RatingApiService {
  _FakeRatingApiService() : super(Dio());

  List<RatingDto> response = [];
  Completer<List<RatingDto>>? completer;
  bool fail = false;
  int? requestedMemberId;
  int? failureStatusCode;

  @override
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    requestedMemberId = memberId;
    if (fail) {
      final request = RequestOptions(path: '/v5/members/$memberId/ratings');
      throw DioException(
        requestOptions: request,
        response: failureStatusCode == null
            ? null
            : Response(requestOptions: request, statusCode: failureStatusCode),
      );
    }
    return completer?.future ?? response;
  }
}

class _FakeTmdbMovieService extends TmdbMovieService {
  _FakeTmdbMovieService() : super(Dio());

  final requestedIds = <int>[];
  final missingIds = <int>{};
  Completer<TmdbMovieDto?>? detailCompleter;

  @override
  Future<TmdbMovieDto?> findMovieById(int movieId) async {
    requestedIds.add(movieId);
    if (missingIds.contains(movieId)) return null;
    return detailCompleter?.future ?? _movie(movieId);
  }
}

TmdbMovieDto _movie(int id) => TmdbMovieDto(
  id: id,
  title: '영화 $id',
  overview: '줄거리 $id',
  posterPath: null,
  backdropPath: null,
  releaseDate: '2020-01-01',
  genreIds: const [18],
  genreNames: const ['드라마'],
  runtimeMinutes: 123,
  voteAverage: 8,
  popularity: 1,
);
