import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/datetime_utc_converter.dart'; // ← add this import

part 'time_entry.freezed.old.dart';
part 'time_entry.g.old.dart';

@freezed
class TimeEntry with _$TimeEntry {
  const TimeEntry._();

  const factory TimeEntry({
    String? id,
    required String userId,
    required String projectId,
    required String clientId,
    String? description,
    @DateTimeUtcConverter() required DateTime startedAt, // ← changed
    @DateTimeUtcConverter() DateTime? endedAt, // ← changed
    @JsonKey(includeToJson: false) double? durationSeconds,
    @Default(0) double hourlyRate,
    @Default(true) bool isBillable,
    @Default(false) bool isBilled,
    String? invoiceId,
    @DateTimeUtcConverter() required DateTime createdAt, // ← changed
  }) = _TimeEntry;

  factory TimeEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryFromJson(json);
}

extension TimeEntryX on TimeEntry {
  bool get isRunning => endedAt == null;

  Duration get duration => endedAt != null
      ? endedAt!.difference(startedAt)
      : DateTime.now().difference(startedAt);

  double get billableAmount => (duration.inSeconds / 3600) * hourlyRate;
}
