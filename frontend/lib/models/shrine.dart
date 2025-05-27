// lib/models/shrine.dart
class Shrine {
  final String imageUrl;
  final String name;
  final String phoneticName;
  final String date;

  Shrine({
    required this.imageUrl,
    required this.name,
    required this.phoneticName,
    required this.date,
  });

  // Factory constructor to create a Shrine object from a JSON map
  factory Shrine.fromJson(Map<String, dynamic> json) {
    return Shrine(
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      phoneticName: json['phoneticName'] as String,
      date: json['date'] as String,
    );
  }
}
