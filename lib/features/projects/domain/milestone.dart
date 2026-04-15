import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone.freezed.dart';
part 'milestone.g.dart';

@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    String? id,
    required String projectId,
    required String userId,
    required String title,
    @Default(false) bool isCompleted,
    DateTime? dueDate,
    @Default(0) int sortOrder,
    DateTime? completedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);
}
