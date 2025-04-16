import 'problem.dart';

class Scene {
  String title;
  String description;
  String? image;
  final List<Problem> problems;

  Scene({
    required this.title,
    required this.description,
    this.image,
    required this.problems,
  });

  factory Scene.fromJson(Map<String, dynamic> json) => Scene(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image: json['image'],
        problems: (json['problems'] as List<dynamic>? ?? [])
            .map((e) => Problem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        if (image != null) 'image': image,
        'problems': problems.map((e) => e.toJson()).toList(),
      };

  Scene copyWith({
    String? title,
    String? description,
    String? image,
    List<Problem>? problems,
  }) {
    return Scene(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      problems: problems ?? this.problems,
    );
  }

  setTitle(String value) => title = value;
  setDescription(String value) => description = value;
  setImage(String? value) => image = value;
}
