import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@freezed
class Client with _$Client {
  const factory Client({
    String? id,
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? country,
    @Default('USD') String currency,
    String? notes,
    @Default('#2563EB') String avatarColor,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
