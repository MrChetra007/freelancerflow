// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      clientId: json['clientId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status:
          $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']) ??
          ProjectStatus.inProgress,
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'clientId': instance.clientId,
      'title': instance.title,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'budget': instance.budget,
      'currency': instance.currency,
      'startDate': instance.startDate?.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.inProgress: 'in_progress',
  ProjectStatus.completed: 'completed',
  ProjectStatus.onHold: 'on_hold',
  ProjectStatus.cancelled: 'cancelled',
};
