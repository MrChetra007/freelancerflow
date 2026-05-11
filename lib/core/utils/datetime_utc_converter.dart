import 'package:json_annotation/json_annotation.dart';

class DateTimeUtcConverter implements JsonConverter<DateTime, String> {
  const DateTimeUtcConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime date) => date.toUtc().toIso8601String();
}
