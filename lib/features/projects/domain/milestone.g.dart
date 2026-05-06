// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilestoneImpl _$$MilestoneImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneImpl(
      id: json['id'] as String?,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$MilestoneImplToJson(_$MilestoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'title': instance.title,
      'is_completed': instance.isCompleted,
      'due_date': instance.dueDate?.toIso8601String(),
      'sort_order': instance.sortOrder,
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
