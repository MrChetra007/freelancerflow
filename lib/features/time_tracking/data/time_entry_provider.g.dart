// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeEntryRepositoryHash() =>
    r'df3644324f183ac3a549fcc300d94cf466842fa3';

/// See also [timeEntryRepository].
@ProviderFor(timeEntryRepository)
final timeEntryRepositoryProvider =
    AutoDisposeProvider<TimeEntryRepository>.internal(
      timeEntryRepository,
      name: r'timeEntryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timeEntryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimeEntryRepositoryRef = AutoDisposeProviderRef<TimeEntryRepository>;
String _$activeTimerHash() => r'a7d7cf2799a95daa33638c8ad515f6cf95ffd095';

/// See also [activeTimer].
@ProviderFor(activeTimer)
final activeTimerProvider = AutoDisposeFutureProvider<TimeEntry?>.internal(
  activeTimer,
  name: r'activeTimerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTimerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTimerRef = AutoDisposeFutureProviderRef<TimeEntry?>;
String _$unbilledTimeEntriesHash() =>
    r'2864a97cc677ba55a086ebf254b71f43247294f3';

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

/// See also [unbilledTimeEntries].
@ProviderFor(unbilledTimeEntries)
const unbilledTimeEntriesProvider = UnbilledTimeEntriesFamily();

/// See also [unbilledTimeEntries].
class UnbilledTimeEntriesFamily extends Family<AsyncValue<List<TimeEntry>>> {
  /// See also [unbilledTimeEntries].
  const UnbilledTimeEntriesFamily();

  /// See also [unbilledTimeEntries].
  UnbilledTimeEntriesProvider call(String clientId) {
    return UnbilledTimeEntriesProvider(clientId);
  }

  @override
  UnbilledTimeEntriesProvider getProviderOverride(
    covariant UnbilledTimeEntriesProvider provider,
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
  String? get name => r'unbilledTimeEntriesProvider';
}

/// See also [unbilledTimeEntries].
class UnbilledTimeEntriesProvider
    extends AutoDisposeFutureProvider<List<TimeEntry>> {
  /// See also [unbilledTimeEntries].
  UnbilledTimeEntriesProvider(String clientId)
    : this._internal(
        (ref) => unbilledTimeEntries(ref as UnbilledTimeEntriesRef, clientId),
        from: unbilledTimeEntriesProvider,
        name: r'unbilledTimeEntriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unbilledTimeEntriesHash,
        dependencies: UnbilledTimeEntriesFamily._dependencies,
        allTransitiveDependencies:
            UnbilledTimeEntriesFamily._allTransitiveDependencies,
        clientId: clientId,
      );

  UnbilledTimeEntriesProvider._internal(
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
    FutureOr<List<TimeEntry>> Function(UnbilledTimeEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnbilledTimeEntriesProvider._internal(
        (ref) => create(ref as UnbilledTimeEntriesRef),
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
  AutoDisposeFutureProviderElement<List<TimeEntry>> createElement() {
    return _UnbilledTimeEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnbilledTimeEntriesProvider && other.clientId == clientId;
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
mixin UnbilledTimeEntriesRef on AutoDisposeFutureProviderRef<List<TimeEntry>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _UnbilledTimeEntriesProviderElement
    extends AutoDisposeFutureProviderElement<List<TimeEntry>>
    with UnbilledTimeEntriesRef {
  _UnbilledTimeEntriesProviderElement(super.provider);

  @override
  String get clientId => (origin as UnbilledTimeEntriesProvider).clientId;
}

String _$allUnbilledTimeEntriesHash() =>
    r'56c064f25e91628fa1c308f728d35083ca2a1ebb';

/// See also [allUnbilledTimeEntries].
@ProviderFor(allUnbilledTimeEntries)
final allUnbilledTimeEntriesProvider =
    AutoDisposeFutureProvider<List<TimeEntry>>.internal(
      allUnbilledTimeEntries,
      name: r'allUnbilledTimeEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allUnbilledTimeEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllUnbilledTimeEntriesRef =
    AutoDisposeFutureProviderRef<List<TimeEntry>>;
String _$projectTimeEntriesHash() =>
    r'250856c2b29f37623373e627c23320d176e5f0ec';

/// See also [projectTimeEntries].
@ProviderFor(projectTimeEntries)
const projectTimeEntriesProvider = ProjectTimeEntriesFamily();

/// See also [projectTimeEntries].
class ProjectTimeEntriesFamily extends Family<AsyncValue<List<TimeEntry>>> {
  /// See also [projectTimeEntries].
  const ProjectTimeEntriesFamily();

  /// See also [projectTimeEntries].
  ProjectTimeEntriesProvider call(String projectId) {
    return ProjectTimeEntriesProvider(projectId);
  }

  @override
  ProjectTimeEntriesProvider getProviderOverride(
    covariant ProjectTimeEntriesProvider provider,
  ) {
    return call(provider.projectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectTimeEntriesProvider';
}

/// See also [projectTimeEntries].
class ProjectTimeEntriesProvider
    extends AutoDisposeStreamProvider<List<TimeEntry>> {
  /// See also [projectTimeEntries].
  ProjectTimeEntriesProvider(String projectId)
    : this._internal(
        (ref) => projectTimeEntries(ref as ProjectTimeEntriesRef, projectId),
        from: projectTimeEntriesProvider,
        name: r'projectTimeEntriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$projectTimeEntriesHash,
        dependencies: ProjectTimeEntriesFamily._dependencies,
        allTransitiveDependencies:
            ProjectTimeEntriesFamily._allTransitiveDependencies,
        projectId: projectId,
      );

  ProjectTimeEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  Override overrideWith(
    Stream<List<TimeEntry>> Function(ProjectTimeEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectTimeEntriesProvider._internal(
        (ref) => create(ref as ProjectTimeEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimeEntry>> createElement() {
    return _ProjectTimeEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectTimeEntriesProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectTimeEntriesRef on AutoDisposeStreamProviderRef<List<TimeEntry>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _ProjectTimeEntriesProviderElement
    extends AutoDisposeStreamProviderElement<List<TimeEntry>>
    with ProjectTimeEntriesRef {
  _ProjectTimeEntriesProviderElement(super.provider);

  @override
  String get projectId => (origin as ProjectTimeEntriesProvider).projectId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
