class Field {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;

  Field({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'category': category,
  };
}
