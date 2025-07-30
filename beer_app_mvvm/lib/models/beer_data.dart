class BeerData {
  final String name;
  final String description;
  final String imageUrl;
  final String category;

  BeerData({
    required this.name,
    required this.description, 
    required this.imageUrl,
    required this.category,
  });

  factory BeerData.fromJson(Map<String, dynamic> json) {
    return BeerData(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  BeerData copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? category,
  }) {
    return BeerData(
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}