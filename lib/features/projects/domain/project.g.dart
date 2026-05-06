// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status:
          $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']) ??
          ProjectStatus.inProgress,
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'client_id': instance.clientId,
      'title': instance.title,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'budget': instance.budget,
      'currency': instance.currency,
      'start_date': instance.startDate?.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'is_archived': instance.isArchived,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.inProgress: 'in_progress',
  ProjectStatus.completed: 'completed',
  ProjectStatus.onHold: 'on_hold',
  ProjectStatus.cancelled: 'cancelled',
};
