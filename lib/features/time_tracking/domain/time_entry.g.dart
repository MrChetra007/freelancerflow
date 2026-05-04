// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeEntryImpl _$$TimeEntryImplFromJson(Map<String, dynamic> json) =>
    _$TimeEntryImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      projectId: json['projectId'] as String,
      clientId: json['clientId'] as String,
      description: json['description'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
      isBillable: json['isBillable'] as bool? ?? true,
      isBilled: json['isBilled'] as bool? ?? false,
      invoiceId: json['invoiceId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TimeEntryImplToJson(_$TimeEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'clientId': instance.clientId,
      'description': instance.description,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'hourlyRate': instance.hourlyRate,
      'isBillable': instance.isBillable,
      'isBilled': instance.isBilled,
      'invoiceId': instance.invoiceId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
