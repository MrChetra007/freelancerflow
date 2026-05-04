// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurringInvoice _$RecurringInvoiceFromJson(Map<String, dynamic> json) {
  return _RecurringInvoice.fromJson(json);
}

/// @nodoc
mixin _$RecurringInvoice {
  String? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  RecurrenceFrequency get frequency => throw _privateConstructorUsedError;
  DateTime get nextIssueDate => throw _privateConstructorUsedError;
  int get dueDays => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<InvoiceLineItem> get lineItems => throw _privateConstructorUsedError;
  double get taxPercent => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get paymentTerms => throw _privateConstructorUsedError;
  int get timesGenerated => throw _privateConstructorUsedError;
  DateTime? get lastGeneratedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RecurringInvoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringInvoiceCopyWith<RecurringInvoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringInvoiceCopyWith<$Res> {
  factory $RecurringInvoiceCopyWith(
    RecurringInvoice value,
    $Res Function(RecurringInvoice) then,
  ) = _$RecurringInvoiceCopyWithImpl<$Res, RecurringInvoice>;
  @useResult
  $Res call({
    String? id,
    String userId,
    String clientId,
    String? projectId,
    RecurrenceFrequency frequency,
    DateTime nextIssueDate,
    int dueDays,
    bool isActive,
    List<InvoiceLineItem> lineItems,
    double taxPercent,
    double discountPercent,
    String currency,
    String? notes,
    String? paymentTerms,
    int timesGenerated,
    DateTime? lastGeneratedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$RecurringInvoiceCopyWithImpl<$Res, $Val extends RecurringInvoice>
    implements $RecurringInvoiceCopyWith<$Res> {
  _$RecurringInvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? clientId = null,
    Object? projectId = freezed,
    Object? frequency = null,
    Object? nextIssueDate = null,
    Object? dueDays = null,
    Object? isActive = null,
    Object? lineItems = null,
    Object? taxPercent = null,
    Object? discountPercent = null,
    Object? currency = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? timesGenerated = null,
    Object? lastGeneratedAt = freezed,
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
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            projectId: freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String?,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as RecurrenceFrequency,
            nextIssueDate: null == nextIssueDate
                ? _value.nextIssueDate
                : nextIssueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dueDays: null == dueDays
                ? _value.dueDays
                : dueDays // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            lineItems: null == lineItems
                ? _value.lineItems
                : lineItems // ignore: cast_nullable_to_non_nullable
                      as List<InvoiceLineItem>,
            taxPercent: null == taxPercent
                ? _value.taxPercent
                : taxPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPercent: null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentTerms: freezed == paymentTerms
                ? _value.paymentTerms
                : paymentTerms // ignore: cast_nullable_to_non_nullable
                      as String?,
            timesGenerated: null == timesGenerated
                ? _value.timesGenerated
                : timesGenerated // ignore: cast_nullable_to_non_nullable
                      as int,
            lastGeneratedAt: freezed == lastGeneratedAt
                ? _value.lastGeneratedAt
                : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$RecurringInvoiceImplCopyWith<$Res>
    implements $RecurringInvoiceCopyWith<$Res> {
  factory _$$RecurringInvoiceImplCopyWith(
    _$RecurringInvoiceImpl value,
    $Res Function(_$RecurringInvoiceImpl) then,
  ) = __$$RecurringInvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String userId,
    String clientId,
    String? projectId,
    RecurrenceFrequency frequency,
    DateTime nextIssueDate,
    int dueDays,
    bool isActive,
    List<InvoiceLineItem> lineItems,
    double taxPercent,
    double discountPercent,
    String currency,
    String? notes,
    String? paymentTerms,
    int timesGenerated,
    DateTime? lastGeneratedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$RecurringInvoiceImplCopyWithImpl<$Res>
    extends _$RecurringInvoiceCopyWithImpl<$Res, _$RecurringInvoiceImpl>
    implements _$$RecurringInvoiceImplCopyWith<$Res> {
  __$$RecurringInvoiceImplCopyWithImpl(
    _$RecurringInvoiceImpl _value,
    $Res Function(_$RecurringInvoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurringInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? clientId = null,
    Object? projectId = freezed,
    Object? frequency = null,
    Object? nextIssueDate = null,
    Object? dueDays = null,
    Object? isActive = null,
    Object? lineItems = null,
    Object? taxPercent = null,
    Object? discountPercent = null,
    Object? currency = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? timesGenerated = null,
    Object? lastGeneratedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$RecurringInvoiceImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: freezed == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String?,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as RecurrenceFrequency,
        nextIssueDate: null == nextIssueDate
            ? _value.nextIssueDate
            : nextIssueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dueDays: null == dueDays
            ? _value.dueDays
            : dueDays // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        lineItems: null == lineItems
            ? _value._lineItems
            : lineItems // ignore: cast_nullable_to_non_nullable
                  as List<InvoiceLineItem>,
        taxPercent: null == taxPercent
            ? _value.taxPercent
            : taxPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPercent: null == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentTerms: freezed == paymentTerms
            ? _value.paymentTerms
            : paymentTerms // ignore: cast_nullable_to_non_nullable
                  as String?,
        timesGenerated: null == timesGenerated
            ? _value.timesGenerated
            : timesGenerated // ignore: cast_nullable_to_non_nullable
                  as int,
        lastGeneratedAt: freezed == lastGeneratedAt
            ? _value.lastGeneratedAt
            : lastGeneratedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$RecurringInvoiceImpl implements _RecurringInvoice {
  const _$RecurringInvoiceImpl({
    this.id,
    required this.userId,
    required this.clientId,
    this.projectId,
    required this.frequency,
    required this.nextIssueDate,
    this.dueDays = 30,
    this.isActive = true,
    final List<InvoiceLineItem> lineItems = const [],
    this.taxPercent = 0,
    this.discountPercent = 0,
    this.currency = 'USD',
    this.notes,
    this.paymentTerms,
    this.timesGenerated = 0,
    this.lastGeneratedAt,
    required this.createdAt,
  }) : _lineItems = lineItems;

  factory _$RecurringInvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringInvoiceImplFromJson(json);

  @override
  final String? id;
  @override
  final String userId;
  @override
  final String clientId;
  @override
  final String? projectId;
  @override
  final RecurrenceFrequency frequency;
  @override
  final DateTime nextIssueDate;
  @override
  @JsonKey()
  final int dueDays;
  @override
  @JsonKey()
  final bool isActive;
  final List<InvoiceLineItem> _lineItems;
  @override
  @JsonKey()
  List<InvoiceLineItem> get lineItems {
    if (_lineItems is EqualUnmodifiableListView) return _lineItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineItems);
  }

  @override
  @JsonKey()
  final double taxPercent;
  @override
  @JsonKey()
  final double discountPercent;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? notes;
  @override
  final String? paymentTerms;
  @override
  @JsonKey()
  final int timesGenerated;
  @override
  final DateTime? lastGeneratedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RecurringInvoice(id: $id, userId: $userId, clientId: $clientId, projectId: $projectId, frequency: $frequency, nextIssueDate: $nextIssueDate, dueDays: $dueDays, isActive: $isActive, lineItems: $lineItems, taxPercent: $taxPercent, discountPercent: $discountPercent, currency: $currency, notes: $notes, paymentTerms: $paymentTerms, timesGenerated: $timesGenerated, lastGeneratedAt: $lastGeneratedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringInvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.nextIssueDate, nextIssueDate) ||
                other.nextIssueDate == nextIssueDate) &&
            (identical(other.dueDays, dueDays) || other.dueDays == dueDays) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(
              other._lineItems,
              _lineItems,
            ) &&
            (identical(other.taxPercent, taxPercent) ||
                other.taxPercent == taxPercent) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.paymentTerms, paymentTerms) ||
                other.paymentTerms == paymentTerms) &&
            (identical(other.timesGenerated, timesGenerated) ||
                other.timesGenerated == timesGenerated) &&
            (identical(other.lastGeneratedAt, lastGeneratedAt) ||
                other.lastGeneratedAt == lastGeneratedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    clientId,
    projectId,
    frequency,
    nextIssueDate,
    dueDays,
    isActive,
    const DeepCollectionEquality().hash(_lineItems),
    taxPercent,
    discountPercent,
    currency,
    notes,
    paymentTerms,
    timesGenerated,
    lastGeneratedAt,
    createdAt,
  );

  /// Create a copy of RecurringInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringInvoiceImplCopyWith<_$RecurringInvoiceImpl> get copyWith =>
      __$$RecurringInvoiceImplCopyWithImpl<_$RecurringInvoiceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringInvoiceImplToJson(this);
  }
}

abstract class _RecurringInvoice implements RecurringInvoice {
  const factory _RecurringInvoice({
    final String? id,
    required final String userId,
    required final String clientId,
    final String? projectId,
    required final RecurrenceFrequency frequency,
    required final DateTime nextIssueDate,
    final int dueDays,
    final bool isActive,
    final List<InvoiceLineItem> lineItems,
    final double taxPercent,
    final double discountPercent,
    final String currency,
    final String? notes,
    final String? paymentTerms,
    final int timesGenerated,
    final DateTime? lastGeneratedAt,
    required final DateTime createdAt,
  }) = _$RecurringInvoiceImpl;

  factory _RecurringInvoice.fromJson(Map<String, dynamic> json) =
      _$RecurringInvoiceImpl.fromJson;

  @override
  String? get id;
  @override
  String get userId;
  @override
  String get clientId;
  @override
  String? get projectId;
  @override
  RecurrenceFrequency get frequency;
  @override
  DateTime get nextIssueDate;
  @override
  int get dueDays;
  @override
  bool get isActive;
  @override
  List<InvoiceLineItem> get lineItems;
  @override
  double get taxPercent;
  @override
  double get discountPercent;
  @override
  String get currency;
  @override
  String? get notes;
  @override
  String? get paymentTerms;
  @override
  int get timesGenerated;
  @override
  DateTime? get lastGeneratedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of RecurringInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringInvoiceImplCopyWith<_$RecurringInvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
