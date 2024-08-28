class UserModel {
  final String username;
  final String profilePic;
  final String uid;
  UserModel({
    required this.username,
    required this.profilePic,
    required this.uid,
  });

  UserModel copyWith({
    String? username,
    String? profilePic,
    String? uid,
    bool? isAuthenticated,
  }) {
    return UserModel(
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'profilePic': profilePic,
      'uid': uid,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
      uid: map['uid'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(username: $username, profilePic: $profilePic, uid: $uid)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.username == username &&
        other.profilePic == profilePic &&
        other.uid == uid;
  }

  @override
  int get hashCode {
    return username.hashCode ^ profilePic.hashCode ^ uid.hashCode;
  }
}
