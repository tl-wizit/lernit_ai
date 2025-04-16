class Problem {
  final String title;
  final String description;
  final String resolution;
  final String? image;

  Problem({
    required this.title,
    required this.description,
    required this.resolution,
    this.image,
  });

  factory Problem.fromJson(Map<String, dynamic> json) => Problem(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        resolution: json['resolution'] ?? '',
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'resolution': resolution,
        if (image != null) 'image': image,
      };

  Problem copyWith({
    String? title,
    String? description,
    String? resolution,
    String? image,
  }) {
    return Problem(
      title: title ?? this.title,
      description: description ?? this.description,
      resolution: resolution ?? this.resolution,
      image: image ?? this.image,
    );
  }
}
