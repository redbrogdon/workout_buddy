class UserPreferences {
  final String description;

  UserPreferences({
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      description: json['description'] as String? ?? '',
    );
  }
}
