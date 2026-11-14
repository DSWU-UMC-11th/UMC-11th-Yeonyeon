class MemberInfo {
  const MemberInfo({this.memberId, required this.email, required this.nickname, required this.createdAt});
  final int? memberId;
  final String email;
  final String nickname;
  final DateTime createdAt;
  factory MemberInfo.fromJson(Map<String, dynamic> json) => MemberInfo(
    memberId: json['memberId'] is num ? (json['memberId'] as num).toInt() : null,
    email: json['email'] as String,
    nickname: json['nickname'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
