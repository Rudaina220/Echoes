import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/memory_entry.dart';
import '../data/memory_repository.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository();
});

final memoriesProvider = Provider<List<MemoryEntry>>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.getAllMemories();
});

final memoryByIdProvider = Provider.family<MemoryEntry?, int>((ref, id) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.getMemoryById(id);
});