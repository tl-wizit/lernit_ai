import 'scene.dart';

class Scenario {
  final String title;
  final String language;
  final String? description;
  final String? image;
  final List<Scene> scenes;
  final DateTime? lastUpdated;

  Scenario({
    required this.title,
    required this.language,
    this.description,
    this.image,
    required this.scenes,
    this.lastUpdated,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) => Scenario(
        title: json['title'] ?? '',
        language: json['language'] ?? 'fr',
        description: json['description'],
        image: json['image'],
        scenes: (json['scenes'] as List<dynamic>? ?? [])
            .map((e) => Scene.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'language': language,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
        'scenes': scenes.map((e) => e.toJson()).toList(),
        if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
      };
}
