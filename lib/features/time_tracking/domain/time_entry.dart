import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_entry.freezed.dart';
part 'time_entry.g.dart';

@freezed
class TimeEntry with _$TimeEntry {
  const TimeEntry._();

  const factory TimeEntry({
    String? id,
    required String userId,
    required String projectId,
    required String clientId,
    String? description,
    required DateTime startedAt,
    DateTime? endedAt,
    @JsonKey(includeToJson: false) double? durationSeconds, // ← must be here
    @Default(0) double hourlyRate,
    @Default(true) bool isBillable,
    @Default(false) bool isBilled,
    String? invoiceId,
    required DateTime createdAt,
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
