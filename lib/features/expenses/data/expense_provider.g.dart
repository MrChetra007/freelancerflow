// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseRepositoryHash() => r'b466e38ae99bdd22a7884925b59cdcd6d08ba11c';

/// See also [expenseRepository].
@ProviderFor(expenseRepository)
final expenseRepositoryProvider =
    AutoDisposeProvider<ExpenseRepository>.internal(
      expenseRepository,
      name: r'expenseRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseRepositoryRef = AutoDisposeProviderRef<ExpenseRepository>;
String _$expensesHash() => r'697e194e11755d576bcc9d8fb4dbf1112cb6bccb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [expenses].
@ProviderFor(expenses)
const expensesProvider = ExpensesFamily();

/// See also [expenses].
class ExpensesFamily extends Family<AsyncValue<List<Expense>>> {
  /// See also [expenses].
  const ExpensesFamily();

  /// See also [expenses].
  ExpensesProvider call({
    String? projectId,
    String? clientId,
    ExpenseCategory? category,
    bool? isBillable,
    bool? isBilled,
  }) {
    return ExpensesProvider(
      projectId: projectId,
      clientId: clientId,
      category: category,
      isBillable: isBillable,
      isBilled: isBilled,
    );
  }

  @override
  ExpensesProvider getProviderOverride(covariant ExpensesProvider provider) {
    return call(
      projectId: provider.projectId,
      clientId: provider.clientId,
      category: provider.category,
      isBillable: provider.isBillable,
      isBilled: provider.isBilled,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'expensesProvider';
}

/// See also [expenses].
class ExpensesProvider extends AutoDisposeFutureProvider<List<Expense>> {
  /// See also [expenses].
  ExpensesProvider({
    String? projectId,
    String? clientId,
    ExpenseCategory? category,
    bool? isBillable,
    bool? isBilled,
  }) : this._internal(
         (ref) => expenses(
           ref as ExpensesRef,
           projectId: projectId,
           clientId: clientId,
           category: category,
           isBillable: isBillable,
           isBilled: isBilled,
         ),
         from: expensesProvider,
         name: r'expensesProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$expensesHash,
         dependencies: ExpensesFamily._dependencies,
         allTransitiveDependencies: ExpensesFamily._allTransitiveDependencies,
         projectId: projectId,
         clientId: clientId,
         category: category,
         isBillable: isBillable,
         isBilled: isBilled,
       );

  ExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
    required this.clientId,
    required this.category,
    required this.isBillable,
    required this.isBilled,
  }) : super.internal();

  final String? projectId;
  final String? clientId;
  final ExpenseCategory? category;
  final bool? isBillable;
  final bool? isBilled;

  @override
  Override overrideWith(
    FutureOr<List<Expense>> Function(ExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpensesProvider._internal(
        (ref) => create(ref as ExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
        clientId: clientId,
        category: category,
        isBillable: isBillable,
        isBilled: isBilled,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Expense>> createElement() {
    return _ExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesProvider &&
        other.projectId == projectId &&
        other.clientId == clientId &&
        other.category == category &&
        other.isBillable == isBillable &&
        other.isBilled == isBilled;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);
    hash = _SystemHash.combine(hash, isBillable.hashCode);
    hash = _SystemHash.combine(hash, isBilled.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExpensesRef on AutoDisposeFutureProviderRef<List<Expense>> {
  /// The parameter `projectId` of this provider.
  String? get projectId;

  /// The parameter `clientId` of this provider.
  String? get clientId;

  /// The parameter `category` of this provider.
  ExpenseCategory? get category;

  /// The parameter `isBillable` of this provider.
  bool? get isBillable;

  /// The parameter `isBilled` of this provider.
  bool? get isBilled;
}

class _ExpensesProviderElement
    extends AutoDisposeFutureProviderElement<List<Expense>>
    with ExpensesRef {
  _ExpensesProviderElement(super.provider);

  @override
  String? get projectId => (origin as ExpensesProvider).projectId;
  @override
  String? get clientId => (origin as ExpensesProvider).clientId;
  @override
  ExpenseCategory? get category => (origin as ExpensesProvider).category;
  @override
  bool? get isBillable => (origin as ExpensesProvider).isBillable;
  @override
  bool? get isBilled => (origin as ExpensesProvider).isBilled;
}

String _$expenseBreakdownHash() => r'38cdc313c733c06fbf8f0d2d57660ebe8787d72d';

/// See also [expenseBreakdown].
@ProviderFor(expenseBreakdown)
const expenseBreakdownProvider = ExpenseBreakdownFamily();

/// See also [expenseBreakdown].
class ExpenseBreakdownFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [expenseBreakdown].
  const ExpenseBreakdownFamily();

  /// See also [expenseBreakdown].
  ExpenseBreakdownProvider call(int months) {
    return ExpenseBreakdownProvider(months);
  }

  @override
  ExpenseBreakdownProvider getProviderOverride(
    covariant ExpenseBreakdownProvider provider,
  ) {
    return call(provider.months);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'expenseBreakdownProvider';
}

/// See also [expenseBreakdown].
class ExpenseBreakdownProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [expenseBreakdown].
  ExpenseBreakdownProvider(int months)
    : this._internal(
        (ref) => expenseBreakdown(ref as ExpenseBreakdownRef, months),
        from: expenseBreakdownProvider,
        name: r'expenseBreakdownProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$expenseBreakdownHash,
        dependencies: ExpenseBreakdownFamily._dependencies,
        allTransitiveDependencies:
            ExpenseBreakdownFamily._allTransitiveDependencies,
        months: months,
      );

  ExpenseBreakdownProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.months,
  }) : super.internal();

  final int months;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(ExpenseBreakdownRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpenseBreakdownProvider._internal(
        (ref) => create(ref as ExpenseBreakdownRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        months: months,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ExpenseBreakdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseBreakdownProvider && other.months == months;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, months.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExpenseBreakdownRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `months` of this provider.
  int get months;
}

class _ExpenseBreakdownProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ExpenseBreakdownRef {
  _ExpenseBreakdownProviderElement(super.provider);

  @override
  int get months => (origin as ExpenseBreakdownProvider).months;
}

String _$unbilledBillableExpensesHash() =>
    r'760bfc6f7f4c6f44c7a91bc8fb29b29363bd0ec0';

/// See also [unbilledBillableExpenses].
@ProviderFor(unbilledBillableExpenses)
const unbilledBillableExpensesProvider = UnbilledBillableExpensesFamily();

/// See also [unbilledBillableExpenses].
class UnbilledBillableExpensesFamily extends Family<AsyncValue<List<Expense>>> {
  /// See also [unbilledBillableExpenses].
  const UnbilledBillableExpensesFamily();

  /// See also [unbilledBillableExpenses].
  UnbilledBillableExpensesProvider call(String clientId) {
    return UnbilledBillableExpensesProvider(clientId);
  }

  @override
  UnbilledBillableExpensesProvider getProviderOverride(
    covariant UnbilledBillableExpensesProvider provider,
  ) {
    return call(provider.clientId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unbilledBillableExpensesProvider';
}

/// See also [unbilledBillableExpenses].
class UnbilledBillableExpensesProvider
    extends AutoDisposeFutureProvider<List<Expense>> {
  /// See also [unbilledBillableExpenses].
  UnbilledBillableExpensesProvider(String clientId)
    : this._internal(
        (ref) => unbilledBillableExpenses(
          ref as UnbilledBillableExpensesRef,
          clientId,
        ),
        from: unbilledBillableExpensesProvider,
        name: r'unbilledBillableExpensesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unbilledBillableExpensesHash,
        dependencies: UnbilledBillableExpensesFamily._dependencies,
        allTransitiveDependencies:
            UnbilledBillableExpensesFamily._allTransitiveDependencies,
        clientId: clientId,
      );

  UnbilledBillableExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    FutureOr<List<Expense>> Function(UnbilledBillableExpensesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnbilledBillableExpensesProvider._internal(
        (ref) => create(ref as UnbilledBillableExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Expense>> createElement() {
    return _UnbilledBillableExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnbilledBillableExpensesProvider &&
        other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnbilledBillableExpensesRef
    on AutoDisposeFutureProviderRef<List<Expense>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _UnbilledBillableExpensesProviderElement
    extends AutoDisposeFutureProviderElement<List<Expense>>
    with UnbilledBillableExpensesRef {
  _UnbilledBillableExpensesProviderElement(super.provider);

  @override
  String get clientId => (origin as UnbilledBillableExpensesProvider).clientId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
