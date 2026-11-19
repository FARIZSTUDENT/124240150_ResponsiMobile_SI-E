class Recipe {
  final int id;
  final String type;
  final String name;
  final String cuisine;
  final String rating;
  final String image;
  final String instructions;

  const Recipe({
    required this.id,
    required this.type,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.image,
    required this.instructions,
  });

  String get key => '$type:$id';

  /// JSON dari API -> objek Article.
  /// `?? ''` = nilai cadangan bila field null (mis. image_url kosong).
  factory Recipe.fromJson(Map<String, dynamic> j, String type) {
    return Recipe(
      id: j['id'] as int,
      type: type,
      name: (j['name'] ?? '') as String,
      cuisine: (j['cuisine'] ?? 'Unknown') as String,
      rating: (j['rating'] ?? '') as String,
      image: (j['image'] ?? '') as String,
      instructions: (j['instructions'] ?? '') as String,
    );
  }

  /// Objek -> Map JSON, untuk disimpan ke sharedPreferences (favorit).
  /// Key-nya sengaja sama dengan JSON API supaya bisa dibaca fromJson lagi.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'cuisine': cuisine,
        'rating': rating,
        'image': image,
        'instructions': instructions,
      };

  /// Membaca data favorit yang tersimpan (type ikut tersimpan di dalamnya).
  factory Recipe.fromStored(Map<String, dynamic> j) =>
      Recipe.fromJson(j, j['type'] as String);
}
