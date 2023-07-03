import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class DatabaseNotOpenException implements Exception {}

class CouldNotDeleteUserException implements Exception {}

class UserAlreadyExistsException implements Exception {}

class CouldNotFindUserException implements Exception {}

class NotesService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) throw DatabaseNotOpenException();
    return db;
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //Create Users Table
      await db.execute(createUsersTable);
      //Create Notes Table
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    db.close();
    _db == null;
  }

  Future<DatabaseUsers> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final queryResult = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (queryResult.isNotEmpty) throw UserAlreadyExistsException();
    final userId = await db.insert(usersTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUsers(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUsers> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final queryResult = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (queryResult.isEmpty) throw CouldNotFindUserException();
    return DatabaseUsers.fromRow(queryResult.first);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(usersTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) throw CouldNotDeleteUserException();
  }
}

@immutable
class DatabaseUsers {
  final int id;
  final String email;

  const DatabaseUsers({
    required this.id,
    required this.email,
  });

  DatabaseUsers.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'User: ID = $id, Email = $email';

  @override
  bool operator ==(covariant DatabaseUsers other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNotes {
  final int id;
  final int userId;
  final String content;
  final bool isSyncedWithCloud;

  const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.content,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        content = map[contentColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note : ID = $id, UserID = $userId, isSyncedWithCloud = $isSyncedWithCloud, Content = $content';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

//constants
const dbName = 'zynotes.db';
const notesTable = 'notes';
const usersTable = 'users';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const contentColumn = 'content';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUsersTable = '''CREATE TABLE IF NOT EXISTS "users" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "content"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "users"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
