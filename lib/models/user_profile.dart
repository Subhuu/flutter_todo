class UserProfile {
  String name;
  int age;
  DateTime lastUpdated;

  UserProfile({
    required this.name,
    required this.age,
    required this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
