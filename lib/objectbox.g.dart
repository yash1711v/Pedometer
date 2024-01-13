// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again:
// With a Flutter package, run `flutter pub run build_runner build`.
// With a Dart package, run `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'LocalDataBaseForSteps/Model.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 982256471633002758),
      name: 'StepsEntity',
      lastPropertyId: const IdUid(6, 4859549916326757292),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 7072610908600835300),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 3246060688955179104),
            name: 'year',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 6306255704944116666),
            name: 'month',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 6918671790090963250),
            name: 'date',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 5327373378635916187),
            name: 'hour',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 4859549916326757292),
            name: 'steps',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Shortcut for [Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [Store.new] for an explanation of all parameters.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// Returns the ObjectBox model definition for this project for use with
/// [Store.new].
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(1, 982256471633002758),
      lastIndexId: const IdUid(0, 0),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    StepsEntity: EntityDefinition<StepsEntity>(
        model: _entities[0],
        toOneRelations: (StepsEntity object) => [],
        toManyRelations: (StepsEntity object) => {},
        getId: (StepsEntity object) => object.id,
        setId: (StepsEntity object, int id) {
          object.id = id;
        },
        objectToFB: (StepsEntity object, fb.Builder fbb) {
          final monthOffset = fbb.writeString(object.month);
          final dateOffset = fbb.writeString(object.date);
          final hourOffset = fbb.writeString(object.hour);
          fbb.startTable(7);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.year);
          fbb.addOffset(2, monthOffset);
          fbb.addOffset(3, dateOffset);
          fbb.addOffset(4, hourOffset);
          fbb.addInt64(5, object.steps);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final yearParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final monthParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final dateParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final hourParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final stepsParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0);
          final object = StepsEntity(
              id: idParam,
              year: yearParam,
              month: monthParam,
              date: dateParam,
              hour: hourParam,
              steps: stepsParam);

          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [StepsEntity] entity fields to define ObjectBox queries.
class StepsEntity_ {
  /// see [StepsEntity.id]
  static final id =
      QueryIntegerProperty<StepsEntity>(_entities[0].properties[0]);

  /// see [StepsEntity.year]
  static final year =
      QueryIntegerProperty<StepsEntity>(_entities[0].properties[1]);

  /// see [StepsEntity.month]
  static final month =
      QueryStringProperty<StepsEntity>(_entities[0].properties[2]);

  /// see [StepsEntity.date]
  static final date =
      QueryStringProperty<StepsEntity>(_entities[0].properties[3]);

  /// see [StepsEntity.hour]
  static final hour =
      QueryStringProperty<StepsEntity>(_entities[0].properties[4]);

  /// see [StepsEntity.steps]
  static final steps =
      QueryIntegerProperty<StepsEntity>(_entities[0].properties[5]);
}
