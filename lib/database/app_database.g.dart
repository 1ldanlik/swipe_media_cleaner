// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class AppStatistics extends Table with TableInfo<AppStatistics, AppStatisticsDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppStatistics(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY CHECK (id = 1)');
  static const VerificationMeta _checkedPhotosMeta = const VerificationMeta('checkedPhotos');
  late final GeneratedColumn<int> checkedPhotos = GeneratedColumn<int>(
      'checked_photos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _deletedPhotosMeta = const VerificationMeta('deletedPhotos');
  late final GeneratedColumn<int> deletedPhotos = GeneratedColumn<int>(
      'deleted_photos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _freedSpaceMeta = const VerificationMeta('freedSpace');
  late final GeneratedColumn<int> freedSpace = GeneratedColumn<int>(
      'freed_space', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns => [id, checkedPhotos, deletedPhotos, freedSpace];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_statistics';
  @override
  VerificationContext validateIntegrity(Insertable<AppStatisticsDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('checked_photos')) {
      context.handle(_checkedPhotosMeta,
          checkedPhotos.isAcceptableOrUnknown(data['checked_photos']!, _checkedPhotosMeta));
    }
    if (data.containsKey('deleted_photos')) {
      context.handle(_deletedPhotosMeta,
          deletedPhotos.isAcceptableOrUnknown(data['deleted_photos']!, _deletedPhotosMeta));
    }
    if (data.containsKey('freed_space')) {
      context.handle(
          _freedSpaceMeta, freedSpace.isAcceptableOrUnknown(data['freed_space']!, _freedSpaceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppStatisticsDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppStatisticsDB(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      checkedPhotos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}checked_photos'])!,
      deletedPhotos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_photos'])!,
      freedSpace: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}freed_space'])!,
    );
  }

  @override
  AppStatistics createAlias(String alias) {
    return AppStatistics(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AppStatisticsDB extends DataClass implements Insertable<AppStatisticsDB> {
  final int id;
  final int checkedPhotos;
  final int deletedPhotos;
  final int freedSpace;
  const AppStatisticsDB(
      {required this.id,
      required this.checkedPhotos,
      required this.deletedPhotos,
      required this.freedSpace});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['checked_photos'] = Variable<int>(checkedPhotos);
    map['deleted_photos'] = Variable<int>(deletedPhotos);
    map['freed_space'] = Variable<int>(freedSpace);
    return map;
  }

  AppStatisticsCompanion toCompanion(bool nullToAbsent) {
    return AppStatisticsCompanion(
      id: Value(id),
      checkedPhotos: Value(checkedPhotos),
      deletedPhotos: Value(deletedPhotos),
      freedSpace: Value(freedSpace),
    );
  }

  factory AppStatisticsDB.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppStatisticsDB(
      id: serializer.fromJson<int>(json['id']),
      checkedPhotos: serializer.fromJson<int>(json['checked_photos']),
      deletedPhotos: serializer.fromJson<int>(json['deleted_photos']),
      freedSpace: serializer.fromJson<int>(json['freed_space']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'checked_photos': serializer.toJson<int>(checkedPhotos),
      'deleted_photos': serializer.toJson<int>(deletedPhotos),
      'freed_space': serializer.toJson<int>(freedSpace),
    };
  }

  AppStatisticsDB copyWith({int? id, int? checkedPhotos, int? deletedPhotos, int? freedSpace}) =>
      AppStatisticsDB(
        id: id ?? this.id,
        checkedPhotos: checkedPhotos ?? this.checkedPhotos,
        deletedPhotos: deletedPhotos ?? this.deletedPhotos,
        freedSpace: freedSpace ?? this.freedSpace,
      );
  AppStatisticsDB copyWithCompanion(AppStatisticsCompanion data) {
    return AppStatisticsDB(
      id: data.id.present ? data.id.value : this.id,
      checkedPhotos: data.checkedPhotos.present ? data.checkedPhotos.value : this.checkedPhotos,
      deletedPhotos: data.deletedPhotos.present ? data.deletedPhotos.value : this.deletedPhotos,
      freedSpace: data.freedSpace.present ? data.freedSpace.value : this.freedSpace,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppStatisticsDB(')
          ..write('id: $id, ')
          ..write('checkedPhotos: $checkedPhotos, ')
          ..write('deletedPhotos: $deletedPhotos, ')
          ..write('freedSpace: $freedSpace')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, checkedPhotos, deletedPhotos, freedSpace);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppStatisticsDB &&
          other.id == this.id &&
          other.checkedPhotos == this.checkedPhotos &&
          other.deletedPhotos == this.deletedPhotos &&
          other.freedSpace == this.freedSpace);
}

class AppStatisticsCompanion extends UpdateCompanion<AppStatisticsDB> {
  final Value<int> id;
  final Value<int> checkedPhotos;
  final Value<int> deletedPhotos;
  final Value<int> freedSpace;
  const AppStatisticsCompanion({
    this.id = const Value.absent(),
    this.checkedPhotos = const Value.absent(),
    this.deletedPhotos = const Value.absent(),
    this.freedSpace = const Value.absent(),
  });
  AppStatisticsCompanion.insert({
    this.id = const Value.absent(),
    this.checkedPhotos = const Value.absent(),
    this.deletedPhotos = const Value.absent(),
    this.freedSpace = const Value.absent(),
  });
  static Insertable<AppStatisticsDB> custom({
    Expression<int>? id,
    Expression<int>? checkedPhotos,
    Expression<int>? deletedPhotos,
    Expression<int>? freedSpace,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkedPhotos != null) 'checked_photos': checkedPhotos,
      if (deletedPhotos != null) 'deleted_photos': deletedPhotos,
      if (freedSpace != null) 'freed_space': freedSpace,
    });
  }

  AppStatisticsCompanion copyWith(
      {Value<int>? id,
      Value<int>? checkedPhotos,
      Value<int>? deletedPhotos,
      Value<int>? freedSpace}) {
    return AppStatisticsCompanion(
      id: id ?? this.id,
      checkedPhotos: checkedPhotos ?? this.checkedPhotos,
      deletedPhotos: deletedPhotos ?? this.deletedPhotos,
      freedSpace: freedSpace ?? this.freedSpace,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (checkedPhotos.present) {
      map['checked_photos'] = Variable<int>(checkedPhotos.value);
    }
    if (deletedPhotos.present) {
      map['deleted_photos'] = Variable<int>(deletedPhotos.value);
    }
    if (freedSpace.present) {
      map['freed_space'] = Variable<int>(freedSpace.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppStatisticsCompanion(')
          ..write('id: $id, ')
          ..write('checkedPhotos: $checkedPhotos, ')
          ..write('deletedPhotos: $deletedPhotos, ')
          ..write('freedSpace: $freedSpace')
          ..write(')'))
        .toString();
  }
}

class ViewedPhotos extends Table with TableInfo<ViewedPhotos, ViewedPhotoDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ViewedPhotos(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  late final GeneratedColumn<int> year = GeneratedColumn<int>('year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  late final GeneratedColumn<int> month = GeneratedColumn<int>('month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  late final GeneratedColumnWithTypeConverter<DateTime, int> viewedAt = GeneratedColumn<int>(
          'viewed_at', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL')
      .withConverter<DateTime>(ViewedPhotos.$converterviewedAt);
  @override
  List<GeneratedColumn> get $columns => [id, year, month, viewedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viewed_photos';
  @override
  VerificationContext validateIntegrity(Insertable<ViewedPhotoDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(_yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(_monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ViewedPhotoDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ViewedPhotoDB(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      year: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      viewedAt: ViewedPhotos.$converterviewedAt.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viewed_at'])!),
    );
  }

  @override
  ViewedPhotos createAlias(String alias) {
    return ViewedPhotos(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterviewedAt = const MillisDateConverter();
  @override
  bool get dontWriteConstraints => true;
}

class ViewedPhotoDB extends DataClass implements Insertable<ViewedPhotoDB> {
  final String id;
  final int year;
  final int month;
  final DateTime viewedAt;
  const ViewedPhotoDB(
      {required this.id, required this.year, required this.month, required this.viewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    {
      map['viewed_at'] = Variable<int>(ViewedPhotos.$converterviewedAt.toSql(viewedAt));
    }
    return map;
  }

  ViewedPhotosCompanion toCompanion(bool nullToAbsent) {
    return ViewedPhotosCompanion(
      id: Value(id),
      year: Value(year),
      month: Value(month),
      viewedAt: Value(viewedAt),
    );
  }

  factory ViewedPhotoDB.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ViewedPhotoDB(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      viewedAt: serializer.fromJson<DateTime>(json['viewed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'viewed_at': serializer.toJson<DateTime>(viewedAt),
    };
  }

  ViewedPhotoDB copyWith({String? id, int? year, int? month, DateTime? viewedAt}) => ViewedPhotoDB(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        viewedAt: viewedAt ?? this.viewedAt,
      );
  ViewedPhotoDB copyWithCompanion(ViewedPhotosCompanion data) {
    return ViewedPhotoDB(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      viewedAt: data.viewedAt.present ? data.viewedAt.value : this.viewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ViewedPhotoDB(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('viewedAt: $viewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, year, month, viewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewedPhotoDB &&
          other.id == this.id &&
          other.year == this.year &&
          other.month == this.month &&
          other.viewedAt == this.viewedAt);
}

class ViewedPhotosCompanion extends UpdateCompanion<ViewedPhotoDB> {
  final Value<String> id;
  final Value<int> year;
  final Value<int> month;
  final Value<DateTime> viewedAt;
  final Value<int> rowid;
  const ViewedPhotosCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.viewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ViewedPhotosCompanion.insert({
    required String id,
    required int year,
    required int month,
    required DateTime viewedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        year = Value(year),
        month = Value(month),
        viewedAt = Value(viewedAt);
  static Insertable<ViewedPhotoDB> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<int>? month,
    Expression<int>? viewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (viewedAt != null) 'viewed_at': viewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ViewedPhotosCompanion copyWith(
      {Value<String>? id,
      Value<int>? year,
      Value<int>? month,
      Value<DateTime>? viewedAt,
      Value<int>? rowid}) {
    return ViewedPhotosCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      viewedAt: viewedAt ?? this.viewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (viewedAt.present) {
      map['viewed_at'] = Variable<int>(ViewedPhotos.$converterviewedAt.toSql(viewedAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViewedPhotosCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('viewedAt: $viewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DeletedPhotos extends Table with TableInfo<DeletedPhotos, DeletedPhotoDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DeletedPhotos(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  late final GeneratedColumn<String> path = GeneratedColumn<String>('path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  late final GeneratedColumn<int> size = GeneratedColumn<int>('size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  late final GeneratedColumnWithTypeConverter<DateTime, int> deletedAt = GeneratedColumn<int>(
          'deleted_at', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL')
      .withConverter<DateTime>(DeletedPhotos.$converterdeletedAt);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  late final GeneratedColumn<int> year = GeneratedColumn<int>('year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  late final GeneratedColumn<int> month = GeneratedColumn<int>('month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, path, size, deletedAt, year, month];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deleted_photos';
  @override
  VerificationContext validateIntegrity(Insertable<DeletedPhotoDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(_pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('size')) {
      context.handle(_sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('year')) {
      context.handle(_yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(_monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeletedPhotoDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeletedPhotoDB(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      path: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      size: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}size'])!,
      deletedAt: DeletedPhotos.$converterdeletedAt.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])!),
      year: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}month'])!,
    );
  }

  @override
  DeletedPhotos createAlias(String alias) {
    return DeletedPhotos(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdeletedAt = const MillisDateConverter();
  @override
  bool get dontWriteConstraints => true;
}

class DeletedPhotoDB extends DataClass implements Insertable<DeletedPhotoDB> {
  final String id;
  final String path;
  final int size;
  final DateTime deletedAt;
  final int year;
  final int month;
  const DeletedPhotoDB(
      {required this.id,
      required this.path,
      required this.size,
      required this.deletedAt,
      required this.year,
      required this.month});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['size'] = Variable<int>(size);
    {
      map['deleted_at'] = Variable<int>(DeletedPhotos.$converterdeletedAt.toSql(deletedAt));
    }
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    return map;
  }

  DeletedPhotosCompanion toCompanion(bool nullToAbsent) {
    return DeletedPhotosCompanion(
      id: Value(id),
      path: Value(path),
      size: Value(size),
      deletedAt: Value(deletedAt),
      year: Value(year),
      month: Value(month),
    );
  }

  factory DeletedPhotoDB.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeletedPhotoDB(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      size: serializer.fromJson<int>(json['size']),
      deletedAt: serializer.fromJson<DateTime>(json['deleted_at']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'size': serializer.toJson<int>(size),
      'deleted_at': serializer.toJson<DateTime>(deletedAt),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
    };
  }

  DeletedPhotoDB copyWith(
          {String? id, String? path, int? size, DateTime? deletedAt, int? year, int? month}) =>
      DeletedPhotoDB(
        id: id ?? this.id,
        path: path ?? this.path,
        size: size ?? this.size,
        deletedAt: deletedAt ?? this.deletedAt,
        year: year ?? this.year,
        month: month ?? this.month,
      );
  DeletedPhotoDB copyWithCompanion(DeletedPhotosCompanion data) {
    return DeletedPhotoDB(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      size: data.size.present ? data.size.value : this.size,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeletedPhotoDB(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('size: $size, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('year: $year, ')
          ..write('month: $month')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, size, deletedAt, year, month);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeletedPhotoDB &&
          other.id == this.id &&
          other.path == this.path &&
          other.size == this.size &&
          other.deletedAt == this.deletedAt &&
          other.year == this.year &&
          other.month == this.month);
}

class DeletedPhotosCompanion extends UpdateCompanion<DeletedPhotoDB> {
  final Value<String> id;
  final Value<String> path;
  final Value<int> size;
  final Value<DateTime> deletedAt;
  final Value<int> year;
  final Value<int> month;
  final Value<int> rowid;
  const DeletedPhotosCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.size = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeletedPhotosCompanion.insert({
    required String id,
    required String path,
    required int size,
    required DateTime deletedAt,
    required int year,
    required int month,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        path = Value(path),
        size = Value(size),
        deletedAt = Value(deletedAt),
        year = Value(year),
        month = Value(month);
  static Insertable<DeletedPhotoDB> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<int>? size,
    Expression<int>? deletedAt,
    Expression<int>? year,
    Expression<int>? month,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (size != null) 'size': size,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeletedPhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? path,
      Value<int>? size,
      Value<DateTime>? deletedAt,
      Value<int>? year,
      Value<int>? month,
      Value<int>? rowid}) {
    return DeletedPhotosCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      size: size ?? this.size,
      deletedAt: deletedAt ?? this.deletedAt,
      year: year ?? this.year,
      month: month ?? this.month,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(DeletedPhotos.$converterdeletedAt.toSql(deletedAt.value));
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeletedPhotosCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('size: $size, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final AppStatistics appStatistics = AppStatistics(this);
  late final ViewedPhotos viewedPhotos = ViewedPhotos(this);
  late final Index viewedPhotosYearMonthIdx = Index('viewed_photos_year_month_idx',
      'CREATE INDEX viewed_photos_year_month_idx ON viewed_photos (year, month)');
  late final Index viewedPhotosViewedAtIdx = Index('viewed_photos_viewed_at_idx',
      'CREATE INDEX viewed_photos_viewed_at_idx ON viewed_photos (viewed_at)');
  late final DeletedPhotos deletedPhotos = DeletedPhotos(this);
  late final Index deletedPhotosYearMonthIdx = Index('deleted_photos_year_month_idx',
      'CREATE INDEX deleted_photos_year_month_idx ON deleted_photos (year, month)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        appStatistics,
        viewedPhotos,
        viewedPhotosYearMonthIdx,
        viewedPhotosViewedAtIdx,
        deletedPhotos,
        deletedPhotosYearMonthIdx
      ];
}

typedef $AppStatisticsCreateCompanionBuilder = AppStatisticsCompanion Function({
  Value<int> id,
  Value<int> checkedPhotos,
  Value<int> deletedPhotos,
  Value<int> freedSpace,
});
typedef $AppStatisticsUpdateCompanionBuilder = AppStatisticsCompanion Function({
  Value<int> id,
  Value<int> checkedPhotos,
  Value<int> deletedPhotos,
  Value<int> freedSpace,
});

class $AppStatisticsFilterComposer extends Composer<_$AppDatabase, AppStatistics> {
  $AppStatisticsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get checkedPhotos =>
      $composableBuilder(column: $table.checkedPhotos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedPhotos =>
      $composableBuilder(column: $table.deletedPhotos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get freedSpace =>
      $composableBuilder(column: $table.freedSpace, builder: (column) => ColumnFilters(column));
}

class $AppStatisticsOrderingComposer extends Composer<_$AppDatabase, AppStatistics> {
  $AppStatisticsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get checkedPhotos => $composableBuilder(
      column: $table.checkedPhotos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedPhotos => $composableBuilder(
      column: $table.deletedPhotos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get freedSpace =>
      $composableBuilder(column: $table.freedSpace, builder: (column) => ColumnOrderings(column));
}

class $AppStatisticsAnnotationComposer extends Composer<_$AppDatabase, AppStatistics> {
  $AppStatisticsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get checkedPhotos =>
      $composableBuilder(column: $table.checkedPhotos, builder: (column) => column);

  GeneratedColumn<int> get deletedPhotos =>
      $composableBuilder(column: $table.deletedPhotos, builder: (column) => column);

  GeneratedColumn<int> get freedSpace =>
      $composableBuilder(column: $table.freedSpace, builder: (column) => column);
}

class $AppStatisticsTableManager extends RootTableManager<
    _$AppDatabase,
    AppStatistics,
    AppStatisticsDB,
    $AppStatisticsFilterComposer,
    $AppStatisticsOrderingComposer,
    $AppStatisticsAnnotationComposer,
    $AppStatisticsCreateCompanionBuilder,
    $AppStatisticsUpdateCompanionBuilder,
    (AppStatisticsDB, BaseReferences<_$AppDatabase, AppStatistics, AppStatisticsDB>),
    AppStatisticsDB,
    PrefetchHooks Function()> {
  $AppStatisticsTableManager(_$AppDatabase db, AppStatistics table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $AppStatisticsFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $AppStatisticsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AppStatisticsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> checkedPhotos = const Value.absent(),
            Value<int> deletedPhotos = const Value.absent(),
            Value<int> freedSpace = const Value.absent(),
          }) =>
              AppStatisticsCompanion(
            id: id,
            checkedPhotos: checkedPhotos,
            deletedPhotos: deletedPhotos,
            freedSpace: freedSpace,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> checkedPhotos = const Value.absent(),
            Value<int> deletedPhotos = const Value.absent(),
            Value<int> freedSpace = const Value.absent(),
          }) =>
              AppStatisticsCompanion.insert(
            id: id,
            checkedPhotos: checkedPhotos,
            deletedPhotos: deletedPhotos,
            freedSpace: freedSpace,
          ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $AppStatisticsProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    AppStatistics,
    AppStatisticsDB,
    $AppStatisticsFilterComposer,
    $AppStatisticsOrderingComposer,
    $AppStatisticsAnnotationComposer,
    $AppStatisticsCreateCompanionBuilder,
    $AppStatisticsUpdateCompanionBuilder,
    (AppStatisticsDB, BaseReferences<_$AppDatabase, AppStatistics, AppStatisticsDB>),
    AppStatisticsDB,
    PrefetchHooks Function()>;
typedef $ViewedPhotosCreateCompanionBuilder = ViewedPhotosCompanion Function({
  required String id,
  required int year,
  required int month,
  required DateTime viewedAt,
  Value<int> rowid,
});
typedef $ViewedPhotosUpdateCompanionBuilder = ViewedPhotosCompanion Function({
  Value<String> id,
  Value<int> year,
  Value<int> month,
  Value<DateTime> viewedAt,
  Value<int> rowid,
});

class $ViewedPhotosFilterComposer extends Composer<_$AppDatabase, ViewedPhotos> {
  $ViewedPhotosFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get viewedAt => $composableBuilder(
      column: $table.viewedAt, builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $ViewedPhotosOrderingComposer extends Composer<_$AppDatabase, ViewedPhotos> {
  $ViewedPhotosOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get viewedAt =>
      $composableBuilder(column: $table.viewedAt, builder: (column) => ColumnOrderings(column));
}

class $ViewedPhotosAnnotationComposer extends Composer<_$AppDatabase, ViewedPhotos> {
  $ViewedPhotosAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get viewedAt =>
      $composableBuilder(column: $table.viewedAt, builder: (column) => column);
}

class $ViewedPhotosTableManager extends RootTableManager<
    _$AppDatabase,
    ViewedPhotos,
    ViewedPhotoDB,
    $ViewedPhotosFilterComposer,
    $ViewedPhotosOrderingComposer,
    $ViewedPhotosAnnotationComposer,
    $ViewedPhotosCreateCompanionBuilder,
    $ViewedPhotosUpdateCompanionBuilder,
    (ViewedPhotoDB, BaseReferences<_$AppDatabase, ViewedPhotos, ViewedPhotoDB>),
    ViewedPhotoDB,
    PrefetchHooks Function()> {
  $ViewedPhotosTableManager(_$AppDatabase db, ViewedPhotos table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $ViewedPhotosFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $ViewedPhotosOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ViewedPhotosAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<DateTime> viewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ViewedPhotosCompanion(
            id: id,
            year: year,
            month: month,
            viewedAt: viewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int year,
            required int month,
            required DateTime viewedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ViewedPhotosCompanion.insert(
            id: id,
            year: year,
            month: month,
            viewedAt: viewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $ViewedPhotosProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    ViewedPhotos,
    ViewedPhotoDB,
    $ViewedPhotosFilterComposer,
    $ViewedPhotosOrderingComposer,
    $ViewedPhotosAnnotationComposer,
    $ViewedPhotosCreateCompanionBuilder,
    $ViewedPhotosUpdateCompanionBuilder,
    (ViewedPhotoDB, BaseReferences<_$AppDatabase, ViewedPhotos, ViewedPhotoDB>),
    ViewedPhotoDB,
    PrefetchHooks Function()>;
typedef $DeletedPhotosCreateCompanionBuilder = DeletedPhotosCompanion Function({
  required String id,
  required String path,
  required int size,
  required DateTime deletedAt,
  required int year,
  required int month,
  Value<int> rowid,
});
typedef $DeletedPhotosUpdateCompanionBuilder = DeletedPhotosCompanion Function({
  Value<String> id,
  Value<String> path,
  Value<int> size,
  Value<DateTime> deletedAt,
  Value<int> year,
  Value<int> month,
  Value<int> rowid,
});

class $DeletedPhotosFilterComposer extends Composer<_$AppDatabase, DeletedPhotos> {
  $DeletedPhotosFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => ColumnFilters(column));
}

class $DeletedPhotosOrderingComposer extends Composer<_$AppDatabase, DeletedPhotos> {
  $DeletedPhotosOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => ColumnOrderings(column));
}

class $DeletedPhotosAnnotationComposer extends Composer<_$AppDatabase, DeletedPhotos> {
  $DeletedPhotosAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);
}

class $DeletedPhotosTableManager extends RootTableManager<
    _$AppDatabase,
    DeletedPhotos,
    DeletedPhotoDB,
    $DeletedPhotosFilterComposer,
    $DeletedPhotosOrderingComposer,
    $DeletedPhotosAnnotationComposer,
    $DeletedPhotosCreateCompanionBuilder,
    $DeletedPhotosUpdateCompanionBuilder,
    (DeletedPhotoDB, BaseReferences<_$AppDatabase, DeletedPhotos, DeletedPhotoDB>),
    DeletedPhotoDB,
    PrefetchHooks Function()> {
  $DeletedPhotosTableManager(_$AppDatabase db, DeletedPhotos table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $DeletedPhotosFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $DeletedPhotosOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DeletedPhotosAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<DateTime> deletedAt = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeletedPhotosCompanion(
            id: id,
            path: path,
            size: size,
            deletedAt: deletedAt,
            year: year,
            month: month,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String path,
            required int size,
            required DateTime deletedAt,
            required int year,
            required int month,
            Value<int> rowid = const Value.absent(),
          }) =>
              DeletedPhotosCompanion.insert(
            id: id,
            path: path,
            size: size,
            deletedAt: deletedAt,
            year: year,
            month: month,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $DeletedPhotosProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    DeletedPhotos,
    DeletedPhotoDB,
    $DeletedPhotosFilterComposer,
    $DeletedPhotosOrderingComposer,
    $DeletedPhotosAnnotationComposer,
    $DeletedPhotosCreateCompanionBuilder,
    $DeletedPhotosUpdateCompanionBuilder,
    (DeletedPhotoDB, BaseReferences<_$AppDatabase, DeletedPhotos, DeletedPhotoDB>),
    DeletedPhotoDB,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $AppStatisticsTableManager get appStatistics =>
      $AppStatisticsTableManager(_db, _db.appStatistics);
  $ViewedPhotosTableManager get viewedPhotos => $ViewedPhotosTableManager(_db, _db.viewedPhotos);
  $DeletedPhotosTableManager get deletedPhotos =>
      $DeletedPhotosTableManager(_db, _db.deletedPhotos);
}
