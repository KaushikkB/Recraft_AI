import 'idea_model.dart';

/// Model representing a saved upcycling project
class SavedItemModel {
  final String id;
  final String objectName;
  final String originalImagePath;
  final List<IdeaModel> ideas;
  final DateTime savedAt;

  SavedItemModel({
    required this.id,
    required this.objectName,
    required this.originalImagePath,
    required this.ideas,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'objectName': objectName,
      'originalImagePath': originalImagePath,
      'ideas': ideas.map((idea) => idea.toJson()).toList(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedItemModel.fromJson(Map<String, dynamic> json) {
    return SavedItemModel(
      id: json['id'] ?? '',
      objectName: json['objectName'] ?? '',
      originalImagePath: json['originalImagePath'] ?? '',
      ideas: (json['ideas'] as List? ?? [])
          .map((ideaJson) => IdeaModel.fromJson(ideaJson))
          .toList(),
      savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}