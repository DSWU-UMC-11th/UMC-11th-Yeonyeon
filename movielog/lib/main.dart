import 'package:flutter/material.dart';

class Movie {
  String title;
  String director;
  Movie({required this.title, required this.director});
}

void main() {
  List<Movie> movies = [
    Movie(title: '기생충', director: '봉준호'),
    Movie(title: '인터스텔라', director: '크리스토퍼 놀란'),
    Movie(title: '라라랜드', director: '데이미언 셔젤'),
  ];

  String? nickname;
  String safeNickname = nickname ?? '익명';

  for (Movie movie in movies) {
    print(movie.title);
  }
  print('닉네임: $safeNickname');
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Flutter 시작!'))),
    ),
  );
}
