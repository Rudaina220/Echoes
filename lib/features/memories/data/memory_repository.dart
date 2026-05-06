import '../../../shared/models/memory_entry.dart';
import '../../../shared/services/objectbox_service.dart';
import '../../../objectbox.g.dart';

class MemoryRepository {
  Box<MemoryEntry> get _box => ObjectBoxService.box;

  List<MemoryEntry> getAllMemories() {
    return _box.query()
        .order(MemoryEntry_.createdAt, flags: Order.descending)
        .build()
        .find();
  }

  MemoryEntry? getMemoryById(int id) {
    return _box.get(id);
  }

  void saveMemory(MemoryEntry entry) {
    _box.put(entry);
  }

  void deleteMemory(int id) {
    _box.remove(id);
  }
}