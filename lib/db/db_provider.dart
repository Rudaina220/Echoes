import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database.dart';

part 'db_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) => AppDatabase();

@riverpod
Stream<List<Memory>> memories(MemoriesRef ref) {
  return ref.watch(databaseProvider).watchAllMemories();
}