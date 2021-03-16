import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:todo_list/app/database/migrations/migration_v1.dart';
//import 'package:todo_list/app/database/migrations/migration_v2.dart';

class Connection {
  static const VERSION = 1;
  static const DATABASE_NAME = 'TODO_LIST';
  static Connection _instance;
  Database _db;
  final _lock = Lock();

  //construtor do tipo factory para podemos ter uma conexão singleton(única)
  factory Connection() {
    if (_instance == null) {
      _instance = Connection._();
    }
    return _instance;
  }

  Connection._(); // construtor nomeado privado

  Future<Database> get instance async => await _openConnection();

  Future<Database> _openConnection() async {
    if (_db == null) {
      // fazer o sincronismo para evitar concorrência de processos
      await _lock.synchronized(() async {
        if (_db == null) {
          var databasePath = await getDatabasesPath();
          var pathDatabase = join(databasePath, DATABASE_NAME);
          print(databasePath);
          _db = await openDatabase(
            pathDatabase,
            version: VERSION,
            onConfigure: _onConfigure,
            onCreate: _onCreate,
            onUpgrade: _onUpgrade,
          );
        }
      });
    }
    return _db;
  }

  void closeConnection() {
    _db?.close();
    _db = null;
  }

  Future<FutureOr<void>> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  FutureOr<void> _onCreate(Database db, int version) {
    var batch = db.batch();
    createV1(batch);
    //createV2(batch);
    batch.commit();
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    //var batch = db.batch();

    //oldVersion = 1
    // if (oldVersion < 2) {
    //   upgradeV2(batch);
    // }

    //oldVersion = 1, oldVersion = 2
    // if (oldVersion < 3) {
    //   //upgradeV3(batch);
    // }

    //batch.commit();
  }
}
