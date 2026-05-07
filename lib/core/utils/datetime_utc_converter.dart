// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart';

class DateTimeUtcConverter implements JsonConverter<DateTime, String> {
  const DateTimeUtcConverter();

  @override
  DateTime fromJson(String json) {
    // Keep as UTC — so it matches DateTime.now().toUtc()
    return DateTime.parse(json).toUtc();
  }

  @override
  String toJson(DateTime date) {
    // Save to Supabase → always store as UTC
    return date.toUtc().toIso8601String();
  }
}
