class Team {
  final String id;
  final String name;
  final String city;
  final String logo;
  final double marketValue;
  final int foundedYear;

  Team({
    required this.id,
    required this.name,
    required this.city,
    required this.logo,
    required this.marketValue,
    required this.foundedYear,
  });

  factory Team.fromJson(Map<String, dynamic> json, String documentId) {
    return Team(
      id: documentId,
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      logo: json['logo'] ?? '',
      marketValue: (json['marketValue'] ?? 0.0).toDouble(),
      foundedYear: json['foundedYear'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'logo': logo,
      'marketValue': marketValue,
      'foundedYear': foundedYear,
    };
  }

  String get fullName => name;
} 