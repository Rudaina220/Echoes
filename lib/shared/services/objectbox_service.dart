import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../objectbox.g.dart';
import '../models/memory_entry.dart';

class ObjectBoxService {
  static Store? _store;
  static Box<MemoryEntry>? _box;

  static Future<void> open() async {
    if (_store != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _store = await openStore(directory: p.join(dir.path, 'objectbox'));
    _box = _store!.box<MemoryEntry>();
  }

  static Box<MemoryEntry> get box {
    if (_box == null) throw StateError('ObjectBoxService not initialized. Call open() first.');
    return _box!;
  }

  static Store get store {
    if (_store == null) throw StateError('ObjectBoxService not initialized. Call open() first.');
    return _store!;
  }

  static void close() {
    _store?.close();
    _store = null;
    _box = null;
  }
}