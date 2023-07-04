import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:zynotes/services/crud/crud_exceptions.dart';

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
    if (queryResult.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUsers.fromRow(queryResult.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(usersTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) throw CouldNotDeleteUserException();
  }

  Future<DatabaseNotes> createNote({required DatabaseUsers owner}) async {
    final db = _getDatabaseOrThrow();

    //Making sure owner exists in the database with the correct ID
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotFindUserException();

    const content = '';

    //Create the note
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      contentColumn: content,
      isSyncedWithCloudColumn: 1,
    });

    return DatabaseNotes(
      id: noteId,
      userId: owner.id,
      content: content,
      isSyncedWithCloud: true,
    );
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) throw CouldNotDeleteNoteException();
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final note = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (note.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return DatabaseNotes.fromRow(note.first);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return notes.map((notesRow) => DatabaseNotes.fromRow(notesRow));
    }
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String content,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(notesTable, {
      contentColumn: content,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      return await getNote(id: note.id);
    }
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
