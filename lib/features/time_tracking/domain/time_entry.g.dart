// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeEntryImpl _$$TimeEntryImplFromJson(Map<String, dynamic> json) =>
    _$TimeEntryImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String,
      clientId: json['client_id'] as String,
      description: json['description'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0,
      isBillable: json['is_billable'] as bool? ?? true,
      isBilled: json['is_billed'] as bool? ?? false,
      invoiceId: json['invoice_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TimeEntryImplToJson(_$TimeEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'project_id': instance.projectId,
      'client_id': instance.clientId,
      'description': instance.description,
      'started_at': instance.startedAt.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'duration_seconds': instance.durationSeconds,
      'hourly_rate': instance.hourlyRate,
      'is_billable': instance.isBillable,
      'is_billed': instance.isBilled,
      'invoice_id': instance.invoiceId,
      'created_at': instance.createdAt.toIso8601String(),
    };
