// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart';

class DateTimeUtcConverter implements JsonConverter<DateTime, String> {
  const DateTimeUtcConverter();

  @override
  DateTime fromJson(String json) {
    // Read from Supabase → convert to device local time for display
    return DateTime.parse(json).toLocal();
  }

  @override
  String toJson(DateTime date) {
    // Save to Supabase → always store as UTC
    return date.toUtc().toIso8601String();
  }
}
