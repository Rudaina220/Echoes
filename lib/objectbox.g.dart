import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int;
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'shared/models/memory_entry.dart';

export 'package:objectbox/objectbox.dart'; 

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 2684228229510979591),
      name: 'MemoryEntry',
      lastPropertyId: const obx_int.IdUid(11, 8898556495082924830),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 2986480562512215029),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 3965632789956779674),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 8967103303874228401),
            name: 'bodyText',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 1684960493917236710),
            name: 'createdAt',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 6767626045841875032),
            name: 'latitude',
            type: 8,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 1964609113847499413),
            name: 'longitude',
            type: 8,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 3798776229861995799),
            name: 'locationName',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 2328375518257317631),
            name: 'voiceMemoPath',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 7982581018522069774),
            name: 'voiceTranscript',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 4397758233435215628),
            name: 'moodScore',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 8898556495082924830),
            name: 'syncedToCloud',
            type: 1,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(1, 2684228229510979591),
      lastIndexId: const obx_int.IdUid(0, 0),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    MemoryEntry: obx_int.EntityDefinition<MemoryEntry>(
        model: _entities[0],
        toOneRelations: (MemoryEntry object) => [],
        toManyRelations: (MemoryEntry object) => {},
        getId: (MemoryEntry object) => object.id,
        setId: (MemoryEntry object, int id) {
          object.id = id;
        },
        objectToFB: (MemoryEntry object, fb.Builder fbb) {
          final titleOffset = fbb.writeString(object.title);
          final bodyTextOffset = fbb.writeString(object.bodyText);
          final locationNameOffset = object.locationName == null
              ? null
              : fbb.writeString(object.locationName!);
          final voiceMemoPathOffset = object.voiceMemoPath == null
              ? null
              : fbb.writeString(object.voiceMemoPath!);
          final voiceTranscriptOffset = object.voiceTranscript == null
              ? null
              : fbb.writeString(object.voiceTranscript!);
          fbb.startTable(12);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, titleOffset);
          fbb.addOffset(2, bodyTextOffset);
          fbb.addInt64(3, object.createdAt.millisecondsSinceEpoch);
          fbb.addFloat64(4, object.latitude);
          fbb.addFloat64(5, object.longitude);
          fbb.addOffset(6, locationNameOffset);
          fbb.addOffset(7, voiceMemoPathOffset);
          fbb.addOffset(8, voiceTranscriptOffset);
          fbb.addInt64(9, object.moodScore);
          fbb.addBool(10, object.syncedToCloud);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = MemoryEntry()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..title = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 6, '')
            ..bodyText = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 8, '')
            ..createdAt = DateTime.fromMillisecondsSinceEpoch(
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0))
            ..latitude = const fb.Float64Reader()
                .vTableGetNullable(buffer, rootOffset, 12)
            ..longitude = const fb.Float64Reader()
                .vTableGetNullable(buffer, rootOffset, 14)
            ..locationName = const fb.StringReader(asciiOptimization: true)
                .vTableGetNullable(buffer, rootOffset, 16)
            ..voiceMemoPath = const fb.StringReader(asciiOptimization: true)
                .vTableGetNullable(buffer, rootOffset, 18)
            ..voiceTranscript = const fb.StringReader(asciiOptimization: true)
                .vTableGetNullable(buffer, rootOffset, 20)
            ..moodScore =
                const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 22)
            ..syncedToCloud =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 24, false);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [MemoryEntry] entity fields to define ObjectBox queries.
class MemoryEntry_ {
  /// See [MemoryEntry.id].
  static final id =
      obx.QueryIntegerProperty<MemoryEntry>(_entities[0].properties[0]);

  /// See [MemoryEntry.title].
  static final title =
      obx.QueryStringProperty<MemoryEntry>(_entities[0].properties[1]);

  /// See [MemoryEntry.bodyText].
  static final bodyText =
      obx.QueryStringProperty<MemoryEntry>(_entities[0].properties[2]);

  /// See [MemoryEntry.createdAt].
  static final createdAt =
      obx.QueryDateProperty<MemoryEntry>(_entities[0].properties[3]);

  /// See [MemoryEntry.latitude].
  static final latitude =
      obx.QueryDoubleProperty<MemoryEntry>(_entities[0].properties[4]);

  /// See [MemoryEntry.longitude].
  static final longitude =
      obx.QueryDoubleProperty<MemoryEntry>(_entities[0].properties[5]);

  /// See [MemoryEntry.locationName].
  static final locationName =
      obx.QueryStringProperty<MemoryEntry>(_entities[0].properties[6]);

  /// See [MemoryEntry.voiceMemoPath].
  static final voiceMemoPath =
      obx.QueryStringProperty<MemoryEntry>(_entities[0].properties[7]);

  /// See [MemoryEntry.voiceTranscript].
  static final voiceTranscript =
      obx.QueryStringProperty<MemoryEntry>(_entities[0].properties[8]);

  /// See [MemoryEntry.moodScore].
  static final moodScore =
      obx.QueryIntegerProperty<MemoryEntry>(_entities[0].properties[9]);

  /// See [MemoryEntry.syncedToCloud].
  static final syncedToCloud =
      obx.QueryBooleanProperty<MemoryEntry>(_entities[0].properties[10]);
}
