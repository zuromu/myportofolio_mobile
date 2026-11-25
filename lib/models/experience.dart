import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Portfolio experience synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    required this.category,
    this.thumbnail = '',
    this.endedAt,
    this.startedAt,
    this.id,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String category;
  @JsonKey(defaultValue: '')
  final String thumbnail;
  @JsonKey(includeToJson: false)
  final DateTime? startedAt;
  final DateTime? endedAt;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

/// Category values used by Django, with the labels shown in the app.
const Map<String, String> experienceCategories = {
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
};
