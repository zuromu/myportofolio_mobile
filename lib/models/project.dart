import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.name,
    required this.techStack,
    required this.description,
    this.githubUrl = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String name;
  final String techStack;
  final String description;
  @JsonKey(defaultValue: '')
  final String githubUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
