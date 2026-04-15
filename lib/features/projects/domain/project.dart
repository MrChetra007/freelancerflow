import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

enum ProjectStatus {
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('on_hold')
  onHold,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Project with _$Project {
  const factory Project({
    String? id,
    required String userId,
    required String clientId,
    required String title,
    String? description,
    @Default(ProjectStatus.inProgress) ProjectStatus status,
    @Default(0) double budget,
    @Default('USD') String currency,
    DateTime? startDate,
    DateTime? deadline,
    DateTime? completedAt,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
