import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Memories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get note => text()();
  // Nullable: user might not pick a location
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  // Comma-separated absolute file paths to saved images
  TextColumn get imagePaths => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Memories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.database.customStatement(
          'ALTER TABLE memories ADD COLUMN latitude REAL;',
        );
        await m.database.customStatement(
          'ALTER TABLE memories ADD COLUMN longitude REAL;',
        );
        await m.database.customStatement(
          'ALTER TABLE memories ADD COLUMN image_paths TEXT;',
        );
      }
    },
  );

  Future<int> insertMemory({
    required String title,
    required String note,
    double? latitude,
    double? longitude,
    List<String>? imagePaths,
  }) {
    return into(memories).insert(
      MemoriesCompanion(
        title: Value(title),
        note: Value(note),
        latitude: Value(latitude),
        longitude: Value(longitude),
        imagePaths: Value(imagePaths?.join(',') ?? ''),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Memory>> allMemories() => select(memories).get();

  Stream<List<Memory>> watchAllMemories() {
    return (select(memories)
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.createdAt,
          mode: OrderingMode.desc,
        ),
      ]))
        .watch();
  }

  Future<void> deleteMemory(int memoryId) {
    return (delete(memories)..where((tbl) => tbl.id.equals(memoryId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'echoes.sqlite'));
    return NativeDatabase(file);
  });
}