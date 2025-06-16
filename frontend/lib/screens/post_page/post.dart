class Post {
  final String id;
  final String username;
  final String userIconUrl; // ユーザーアイコンのURL
  final String imageUrl; // 投稿写真のURL
  final String locationName; // 場所の名前
  final DateTime timestamp;

  Post({
    required this.id,
    required this.username,
    required this.userIconUrl,
    required this.imageUrl,
    required this.locationName,
    required this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      username: json['username'],
      userIconUrl: json['userIconUrl'],
      imageUrl: json['imageUrl'],
      locationName: json['locationName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userIconUrl': userIconUrl,
      'imageUrl': imageUrl,
      'locationName': locationName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
