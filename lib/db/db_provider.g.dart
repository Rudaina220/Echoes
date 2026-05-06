part of 'db_provider.dart';

String _$databaseHash() => r'9facb325745d0aa7241f58d2bae29c7610777852';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$memoriesHash() => r'214291be105bcefa276080a45a51a5a2a7066315';

/// See also [memories].
@ProviderFor(memories)
final memoriesProvider = AutoDisposeStreamProvider<List<Memory>>.internal(
  memories,
  name: r'memoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef MemoriesRef = AutoDisposeStreamProviderRef<List<Memory>>;
