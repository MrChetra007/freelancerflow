// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_line_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InvoiceLineItem _$InvoiceLineItemFromJson(Map<String, dynamic> json) {
  return _InvoiceLineItem.fromJson(json);
}

/// @nodoc
mixin _$InvoiceLineItem {
  String get description => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this InvoiceLineItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvoiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceLineItemCopyWith<InvoiceLineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceLineItemCopyWith<$Res> {
  factory $InvoiceLineItemCopyWith(
    InvoiceLineItem value,
    $Res Function(InvoiceLineItem) then,
  ) = _$InvoiceLineItemCopyWithImpl<$Res, InvoiceLineItem>;
  @useResult
  $Res call({
    String description,
    double quantity,
    double unitPrice,
    int sortOrder,
  });
}

/// @nodoc
class _$InvoiceLineItemCopyWithImpl<$Res, $Val extends InvoiceLineItem>
    implements $InvoiceLineItemCopyWith<$Res> {
  _$InvoiceLineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvoiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvoiceLineItemImplCopyWith<$Res>
    implements $InvoiceLineItemCopyWith<$Res> {
  factory _$$InvoiceLineItemImplCopyWith(
    _$InvoiceLineItemImpl value,
    $Res Function(_$InvoiceLineItemImpl) then,
  ) = __$$InvoiceLineItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String description,
    double quantity,
    double unitPrice,
    int sortOrder,
  });
}

/// @nodoc
class __$$InvoiceLineItemImplCopyWithImpl<$Res>
    extends _$InvoiceLineItemCopyWithImpl<$Res, _$InvoiceLineItemImpl>
    implements _$$InvoiceLineItemImplCopyWith<$Res> {
  __$$InvoiceLineItemImplCopyWithImpl(
    _$InvoiceLineItemImpl _value,
    $Res Function(_$InvoiceLineItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvoiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _$InvoiceLineItemImpl(
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceLineItemImpl implements _InvoiceLineItem {
  const _$InvoiceLineItemImpl({
    required this.description,
    this.quantity = 1,
    this.unitPrice = 0,
    this.sortOrder = 0,
  });

  factory _$InvoiceLineItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceLineItemImplFromJson(json);

  @override
  final String description;
  @override
  @JsonKey()
  final double quantity;
  @override
  @JsonKey()
  final double unitPrice;
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'InvoiceLineItem(description: $description, quantity: $quantity, unitPrice: $unitPrice, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceLineItemImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, description, quantity, unitPrice, sortOrder);

  /// Create a copy of InvoiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceLineItemImplCopyWith<_$InvoiceLineItemImpl> get copyWith =>
      __$$InvoiceLineItemImplCopyWithImpl<_$InvoiceLineItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceLineItemImplToJson(this);
  }
}

abstract class _InvoiceLineItem implements InvoiceLineItem {
  const factory _InvoiceLineItem({
    required final String description,
    final double quantity,
    final double unitPrice,
    final int sortOrder,
  }) = _$InvoiceLineItemImpl;

  factory _InvoiceLineItem.fromJson(Map<String, dynamic> json) =
      _$InvoiceLineItemImpl.fromJson;

  @override
  String get description;
  @override
  double get quantity;
  @override
  double get unitPrice;
  @override
  int get sortOrder;

  /// Create a copy of InvoiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceLineItemImplCopyWith<_$InvoiceLineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
