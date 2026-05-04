// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) {
  return _TimeEntry.fromJson(json);
}

/// @nodoc
mixin _$TimeEntry {
  String? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get projectId => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  double? get durationSeconds => throw _privateConstructorUsedError;
  double get hourlyRate => throw _privateConstructorUsedError;
  bool get isBillable => throw _privateConstructorUsedError;
  bool get isBilled => throw _privateConstructorUsedError;
  String? get invoiceId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TimeEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeEntryCopyWith<TimeEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeEntryCopyWith<$Res> {
  factory $TimeEntryCopyWith(TimeEntry value, $Res Function(TimeEntry) then) =
      _$TimeEntryCopyWithImpl<$Res, TimeEntry>;
  @useResult
  $Res call({
    String? id,
    String userId,
    String projectId,
    String clientId,
    String? description,
    DateTime startedAt,
    DateTime? endedAt,
    double? durationSeconds,
    double hourlyRate,
    bool isBillable,
    bool isBilled,
    String? invoiceId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$TimeEntryCopyWithImpl<$Res, $Val extends TimeEntry>
    implements $TimeEntryCopyWith<$Res> {
  _$TimeEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? projectId = null,
    Object? clientId = null,
    Object? description = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? durationSeconds = freezed,
    Object? hourlyRate = null,
    Object? isBillable = null,
    Object? isBilled = null,
    Object? invoiceId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            projectId: null == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationSeconds: freezed == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as double?,
            hourlyRate: null == hourlyRate
                ? _value.hourlyRate
                : hourlyRate // ignore: cast_nullable_to_non_nullable
                      as double,
            isBillable: null == isBillable
                ? _value.isBillable
                : isBillable // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBilled: null == isBilled
                ? _value.isBilled
                : isBilled // ignore: cast_nullable_to_non_nullable
                      as bool,
            invoiceId: freezed == invoiceId
                ? _value.invoiceId
                : invoiceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeEntryImplCopyWith<$Res>
    implements $TimeEntryCopyWith<$Res> {
  factory _$$TimeEntryImplCopyWith(
    _$TimeEntryImpl value,
    $Res Function(_$TimeEntryImpl) then,
  ) = __$$TimeEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String userId,
    String projectId,
    String clientId,
    String? description,
    DateTime startedAt,
    DateTime? endedAt,
    double? durationSeconds,
    double hourlyRate,
    bool isBillable,
    bool isBilled,
    String? invoiceId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$TimeEntryImplCopyWithImpl<$Res>
    extends _$TimeEntryCopyWithImpl<$Res, _$TimeEntryImpl>
    implements _$$TimeEntryImplCopyWith<$Res> {
  __$$TimeEntryImplCopyWithImpl(
    _$TimeEntryImpl _value,
    $Res Function(_$TimeEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? projectId = null,
    Object? clientId = null,
    Object? description = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? durationSeconds = freezed,
    Object? hourlyRate = null,
    Object? isBillable = null,
    Object? isBilled = null,
    Object? invoiceId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$TimeEntryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: null == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationSeconds: freezed == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as double?,
        hourlyRate: null == hourlyRate
            ? _value.hourlyRate
            : hourlyRate // ignore: cast_nullable_to_non_nullable
                  as double,
        isBillable: null == isBillable
            ? _value.isBillable
            : isBillable // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBilled: null == isBilled
            ? _value.isBilled
            : isBilled // ignore: cast_nullable_to_non_nullable
                  as bool,
        invoiceId: freezed == invoiceId
            ? _value.invoiceId
            : invoiceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeEntryImpl extends _TimeEntry {
  const _$TimeEntryImpl({
    this.id,
    required this.userId,
    required this.projectId,
    required this.clientId,
    this.description,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.hourlyRate = 0,
    this.isBillable = true,
    this.isBilled = false,
    this.invoiceId,
    required this.createdAt,
  }) : super._();

  factory _$TimeEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeEntryImplFromJson(json);

  @override
  final String? id;
  @override
  final String userId;
  @override
  final String projectId;
  @override
  final String clientId;
  @override
  final String? description;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final double? durationSeconds;
  @override
  @JsonKey()
  final double hourlyRate;
  @override
  @JsonKey()
  final bool isBillable;
  @override
  @JsonKey()
  final bool isBilled;
  @override
  final String? invoiceId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TimeEntry(id: $id, userId: $userId, projectId: $projectId, clientId: $clientId, description: $description, startedAt: $startedAt, endedAt: $endedAt, durationSeconds: $durationSeconds, hourlyRate: $hourlyRate, isBillable: $isBillable, isBilled: $isBilled, invoiceId: $invoiceId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.hourlyRate, hourlyRate) ||
                other.hourlyRate == hourlyRate) &&
            (identical(other.isBillable, isBillable) ||
                other.isBillable == isBillable) &&
            (identical(other.isBilled, isBilled) ||
                other.isBilled == isBilled) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    projectId,
    clientId,
    description,
    startedAt,
    endedAt,
    durationSeconds,
    hourlyRate,
    isBillable,
    isBilled,
    invoiceId,
    createdAt,
  );

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeEntryImplCopyWith<_$TimeEntryImpl> get copyWith =>
      __$$TimeEntryImplCopyWithImpl<_$TimeEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeEntryImplToJson(this);
  }
}

abstract class _TimeEntry extends TimeEntry {
  const factory _TimeEntry({
    final String? id,
    required final String userId,
    required final String projectId,
    required final String clientId,
    final String? description,
    required final DateTime startedAt,
    final DateTime? endedAt,
    final double? durationSeconds,
    final double hourlyRate,
    final bool isBillable,
    final bool isBilled,
    final String? invoiceId,
    required final DateTime createdAt,
  }) = _$TimeEntryImpl;
  const _TimeEntry._() : super._();

  factory _TimeEntry.fromJson(Map<String, dynamic> json) =
      _$TimeEntryImpl.fromJson;

  @override
  String? get id;
  @override
  String get userId;
  @override
  String get projectId;
  @override
  String get clientId;
  @override
  String? get description;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  double? get durationSeconds;
  @override
  double get hourlyRate;
  @override
  bool get isBillable;
  @override
  bool get isBilled;
  @override
  String? get invoiceId;
  @override
  DateTime get createdAt;

  /// Create a copy of TimeEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeEntryImplCopyWith<_$TimeEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
