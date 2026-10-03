class GuideProfile {
  final String name;
  final String title;
  final String avatarUrl;
  final String coverUrl;
  final double rating;
  final int reviewsCount;
  final String location;
  final int languagesCount;
  final double pricePerHour;
  final List<String> languages;
  final String about;

  const GuideProfile({
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.coverUrl,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.languagesCount,
    required this.pricePerHour,
    required this.languages,
    required this.about,
  });

  factory GuideProfile.fromJson(Map<String, dynamic> json) {
    return GuideProfile(
      name: json['name'] as String,
      title: json['title'] as String,
      avatarUrl: json['avatarUrl'] as String,
      coverUrl: json['coverUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      location: json['location'] as String,
      languagesCount: json['languagesCount'] as int,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      languages: (json['languages'] as List).map((e) => e as String).toList(),
      about: json['about'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'location': location,
      'languagesCount': languagesCount,
      'pricePerHour': pricePerHour,
      'languages': languages,
      'about': about,
    };
  }
}
