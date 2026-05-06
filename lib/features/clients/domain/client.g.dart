// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  company: json['company'] as String?,
  country: json['country'] as String?,
  currency: json['currency'] as String? ?? 'USD',
  notes: json['notes'] as String?,
  avatarColor: json['avatar_color'] as String? ?? '#2563EB',
  isArchived: json['is_archived'] as bool? ?? false,
  defaultHourlyRate: (json['default_hourly_rate'] as num?)?.toDouble() ?? 0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'company': instance.company,
      'country': instance.country,
      'currency': instance.currency,
      'notes': instance.notes,
      'avatar_color': instance.avatarColor,
      'is_archived': instance.isArchived,
      'default_hourly_rate': instance.defaultHourlyRate,
      'tags': instance.tags,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
