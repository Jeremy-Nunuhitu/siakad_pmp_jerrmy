/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class SiakadState
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  SiakadState._({
    this.id,
    required this.key,
    required this.value,
  });

  factory SiakadState({
    int? id,
    required String key,
    required String value,
  }) = _SiakadStateImpl;

  factory SiakadState.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiakadState(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  static final t = SiakadStateTable();

  static const db = SiakadStateRepository._();

  @override
  int? id;

  String key;

  String value;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [SiakadState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SiakadState copyWith({
    int? id,
    String? key,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiakadState',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiakadState',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  static SiakadStateInclude include() {
    return SiakadStateInclude._();
  }

  static SiakadStateIncludeList includeList({
    _i1.WhereExpressionBuilder<SiakadStateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SiakadStateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SiakadStateTable>? orderByList,
    SiakadStateInclude? include,
  }) {
    return SiakadStateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiakadState.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SiakadState.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiakadStateImpl extends SiakadState {
  _SiakadStateImpl({
    int? id,
    required String key,
    required String value,
  }) : super._(
         id: id,
         key: key,
         value: value,
       );

  /// Returns a shallow copy of this [SiakadState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SiakadState copyWith({
    Object? id = _Undefined,
    String? key,
    String? value,
  }) {
    return SiakadState(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}

class SiakadStateUpdateTable extends _i1.UpdateTable<SiakadStateTable> {
  SiakadStateUpdateTable(super.table);

  _i1.ColumnValue<String, String> key(String value) => _i1.ColumnValue(
    table.key,
    value,
  );

  _i1.ColumnValue<String, String> value(String value) => _i1.ColumnValue(
    table.value,
    value,
  );
}

class SiakadStateTable extends _i1.Table<int?> {
  SiakadStateTable({super.tableRelation}) : super(tableName: 'siakad_state') {
    updateTable = SiakadStateUpdateTable(this);
    key = _i1.ColumnString(
      'key',
      this,
    );
    value = _i1.ColumnString(
      'value',
      this,
    );
  }

  late final SiakadStateUpdateTable updateTable;

  late final _i1.ColumnString key;

  late final _i1.ColumnString value;

  @override
  List<_i1.Column> get columns => [
    id,
    key,
    value,
  ];
}

class SiakadStateInclude extends _i1.IncludeObject {
  SiakadStateInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => SiakadState.t;
}

class SiakadStateIncludeList extends _i1.IncludeList {
  SiakadStateIncludeList._({
    _i1.WhereExpressionBuilder<SiakadStateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SiakadState.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => SiakadState.t;
}

class SiakadStateRepository {
  const SiakadStateRepository._();

  /// Returns a list of [SiakadState]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SiakadState>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SiakadStateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SiakadStateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SiakadStateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SiakadState>(
      where: where?.call(SiakadState.t),
      orderBy: orderBy?.call(SiakadState.t),
      orderByList: orderByList?.call(SiakadState.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SiakadState] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SiakadState?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SiakadStateTable>? where,
    int? offset,
    _i1.OrderByBuilder<SiakadStateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SiakadStateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SiakadState>(
      where: where?.call(SiakadState.t),
      orderBy: orderBy?.call(SiakadState.t),
      orderByList: orderByList?.call(SiakadState.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SiakadState] by its [id] or null if no such row exists.
  Future<SiakadState?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SiakadState>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SiakadState]s in the list and returns the inserted rows.
  ///
  /// The returned [SiakadState]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<SiakadState>> insert(
    _i1.DatabaseSession session,
    List<SiakadState> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SiakadState>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SiakadState] and returns the inserted row.
  ///
  /// The returned [SiakadState] will have its `id` field set.
  Future<SiakadState> insertRow(
    _i1.DatabaseSession session,
    SiakadState row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SiakadState>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SiakadState]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SiakadState>> update(
    _i1.DatabaseSession session,
    List<SiakadState> rows, {
    _i1.ColumnSelections<SiakadStateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SiakadState>(
      rows,
      columns: columns?.call(SiakadState.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SiakadState]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SiakadState> updateRow(
    _i1.DatabaseSession session,
    SiakadState row, {
    _i1.ColumnSelections<SiakadStateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SiakadState>(
      row,
      columns: columns?.call(SiakadState.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SiakadState] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SiakadState?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<SiakadStateUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SiakadState>(
      id,
      columnValues: columnValues(SiakadState.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SiakadState]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SiakadState>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SiakadStateUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SiakadStateTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SiakadStateTable>? orderBy,
    _i1.OrderByListBuilder<SiakadStateTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SiakadState>(
      columnValues: columnValues(SiakadState.t.updateTable),
      where: where(SiakadState.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiakadState.t),
      orderByList: orderByList?.call(SiakadState.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SiakadState]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SiakadState>> delete(
    _i1.DatabaseSession session,
    List<SiakadState> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SiakadState>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SiakadState].
  Future<SiakadState> deleteRow(
    _i1.DatabaseSession session,
    SiakadState row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SiakadState>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SiakadState>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SiakadStateTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SiakadState>(
      where: where(SiakadState.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SiakadStateTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SiakadState>(
      where: where?.call(SiakadState.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SiakadState] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SiakadStateTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SiakadState>(
      where: where(SiakadState.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
