// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return _Expense.fromJson(json);
}

/// @nodoc
mixin _$Expense {
  String? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  String? get clientId => throw _privateConstructorUsedError;
  ExpenseCategory get category => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String? get receiptUrl => throw _privateConstructorUsedError;
  bool get isBillable => throw _privateConstructorUsedError;
  bool get isBilled => throw _privateConstructorUsedError;
  String? get invoiceId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCopyWith<Expense> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCopyWith<$Res> {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) then) =
      _$ExpenseCopyWithImpl<$Res, Expense>;
  @useResult
  $Res call({
    String? id,
    String userId,
    String? projectId,
    String? clientId,
    ExpenseCategory category,
    String description,
    double amount,
    String currency,
    DateTime date,
    String? receiptUrl,
    bool isBillable,
    bool isBilled,
    String? invoiceId,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ExpenseCopyWithImpl<$Res, $Val extends Expense>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? projectId = freezed,
    Object? clientId = freezed,
    Object? category = null,
    Object? description = null,
    Object? amount = null,
    Object? currency = null,
    Object? date = null,
    Object? receiptUrl = freezed,
    Object? isBillable = null,
    Object? isBilled = null,
    Object? invoiceId = freezed,
    Object? notes = freezed,
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
            projectId: freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientId: freezed == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as ExpenseCategory,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            receiptUrl: freezed == receiptUrl
                ? _value.receiptUrl
                : receiptUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ExpenseImplCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$$ExpenseImplCopyWith(
    _$ExpenseImpl value,
    $Res Function(_$ExpenseImpl) then,
  ) = __$$ExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String userId,
    String? projectId,
    String? clientId,
    ExpenseCategory category,
    String description,
    double amount,
    String currency,
    DateTime date,
    String? receiptUrl,
    bool isBillable,
    bool isBilled,
    String? invoiceId,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ExpenseImplCopyWithImpl<$Res>
    extends _$ExpenseCopyWithImpl<$Res, _$ExpenseImpl>
    implements _$$ExpenseImplCopyWith<$Res> {
  __$$ExpenseImplCopyWithImpl(
    _$ExpenseImpl _value,
    $Res Function(_$ExpenseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? projectId = freezed,
    Object? clientId = freezed,
    Object? category = null,
    Object? description = null,
    Object? amount = null,
    Object? currency = null,
    Object? date = null,
    Object? receiptUrl = freezed,
    Object? isBillable = null,
    Object? isBilled = null,
    Object? invoiceId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ExpenseImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: freezed == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientId: freezed == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as ExpenseCategory,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        receiptUrl: freezed == receiptUrl
            ? _value.receiptUrl
            : receiptUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$ExpenseImpl implements _Expense {
  const _$ExpenseImpl({
    this.id,
    required this.userId,
    this.projectId,
    this.clientId,
    required this.category,
    required this.description,
    required this.amount,
    this.currency = 'USD',
    required this.date,
    this.receiptUrl,
    this.isBillable = false,
    this.isBilled = false,
    this.invoiceId,
    this.notes,
    required this.createdAt,
  });

  factory _$ExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseImplFromJson(json);

  @override
  final String? id;
  @override
  final String userId;
  @override
  final String? projectId;
  @override
  final String? clientId;
  @override
  final ExpenseCategory category;
  @override
  final String description;
  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;
  @override
  final DateTime date;
  @override
  final String? receiptUrl;
  @override
  @JsonKey()
  final bool isBillable;
  @override
  @JsonKey()
  final bool isBilled;
  @override
  final String? invoiceId;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Expense(id: $id, userId: $userId, projectId: $projectId, clientId: $clientId, category: $category, description: $description, amount: $amount, currency: $currency, date: $date, receiptUrl: $receiptUrl, isBillable: $isBillable, isBilled: $isBilled, invoiceId: $invoiceId, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl) &&
            (identical(other.isBillable, isBillable) ||
                other.isBillable == isBillable) &&
            (identical(other.isBilled, isBilled) ||
                other.isBilled == isBilled) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
    category,
    description,
    amount,
    currency,
    date,
    receiptUrl,
    isBillable,
    isBilled,
    invoiceId,
    notes,
    createdAt,
  );

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      __$$ExpenseImplCopyWithImpl<_$ExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseImplToJson(this);
  }
}

abstract class _Expense implements Expense {
  const factory _Expense({
    final String? id,
    required final String userId,
    final String? projectId,
    final String? clientId,
    required final ExpenseCategory category,
    required final String description,
    required final double amount,
    final String currency,
    required final DateTime date,
    final String? receiptUrl,
    final bool isBillable,
    final bool isBilled,
    final String? invoiceId,
    final String? notes,
    required final DateTime createdAt,
  }) = _$ExpenseImpl;

  factory _Expense.fromJson(Map<String, dynamic> json) = _$ExpenseImpl.fromJson;

  @override
  String? get id;
  @override
  String get userId;
  @override
  String? get projectId;
  @override
  String? get clientId;
  @override
  ExpenseCategory get category;
  @override
  String get description;
  @override
  double get amount;
  @override
  String get currency;
  @override
  DateTime get date;
  @override
  String? get receiptUrl;
  @override
  bool get isBillable;
  @override
  bool get isBilled;
  @override
  String? get invoiceId;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
