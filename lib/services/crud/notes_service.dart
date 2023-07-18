// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'package:zynotes/extensions/filter.dart';
// import 'package:zynotes/services/crud/crud_exceptions.dart';

// class NotesService {
//   Database? _db;
//   int number = 0;
//   List<DatabaseNotes> _notes = [];

//   DatabaseUsers? _user;

//   late final StreamController<List<DatabaseNotes>> _notesStreamController;

//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   static final NotesService _shared = NotesService._sharedInstance();
//   factory NotesService() => _shared;

//   Stream<List<DatabaseNotes>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotesException();
//         }
//       });

//   Future<void> _cachedNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) throw DatabaseNotOpenException();
//     return db;
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //empty
//     }
//   }

//   Future<DatabaseUsers> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) _user = user;
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) _user = createdUser;
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       //Create Users Table
//       await db.execute(createUsersTable);
//       //Create Notes Table
//       await db.execute(createNotesTable);
//       await _cachedNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectoryException();
//     }
//   }

//   Future<void> close() async {
//     final db = _getDatabaseOrThrow();
//     db.close();
//     _db == null;
//   }

//   Future<DatabaseUsers> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final queryResult = await db.query(
//       usersTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (queryResult.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     } else {
//       final userId = await db.insert(usersTable, {
//         emailColumn: email.toLowerCase(),
//       });
//       return DatabaseUsers(
//         id: userId,
//         email: email,
//       );
//     }
//   }

//   Future<DatabaseUsers> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final queryResult = await db.query(
//       usersTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (queryResult.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUsers.fromRow(queryResult.first);
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(usersTable,
//         where: 'email = ?', whereArgs: [email.toLowerCase()]);
//     if (deletedCount != 1) throw CouldNotDeleteUserException();
//   }

//   Future<DatabaseNotes> createNote({required DatabaseUsers owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     //Making sure owner exists in the database with the correct ID
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) throw CouldNotFindUserException();

//     const content = '';

//     //Create the note
//     final noteId = await db.insert(notesTable, {
//       userIdColumn: owner.id,
//       contentColumn: content,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNotes(
//       id: noteId,
//       userId: owner.id,
//       content: content,
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       notesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (deletedCount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((element) => element.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(notesTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return deletedCount;
//   }

//   Future<DatabaseNotes> getNote({required int id}) async {
//     final db = _getDatabaseOrThrow();
//     final note = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (note.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       return DatabaseNotes.fromRow(note.first);
//     }
//   }

//   Future<Iterable<DatabaseNotes>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(notesTable);

//     if (notes.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
//     }
//   }

//   Future<DatabaseNotes> updateNote({
//     required DatabaseNotes note,
//     required String content,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     //Make sure note exists
//     await getNote(id: note.id);

//     //Update DB
//     final updateCount = await db.update(
//       notesTable,
//       {
//         contentColumn: content,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//     if (updateCount == 0) {
//       throw CouldNotUpdateNoteException();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((element) => element.id == note.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }
// }

// @immutable
// class DatabaseUsers {
//   final int id;
//   final String email;

//   const DatabaseUsers({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUsers.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'User: ID = $id, Email = $email';

//   @override
//   bool operator ==(covariant DatabaseUsers other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// @immutable
// class DatabaseNotes {
//   final int id;
//   final int userId;
//   final String content;
//   final bool isSyncedWithCloud;

//   const DatabaseNotes({
//     required this.id,
//     required this.userId,
//     required this.content,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNotes.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         content = map[contentColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Note : ID = $id, UserID = $userId, isSyncedWithCloud = $isSyncedWithCloud, Content = $content';

//   @override
//   bool operator ==(covariant DatabaseNotes other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// //constants
// const dbName = 'zynotes.db';
// const notesTable = 'notes';
// const usersTable = 'users';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const contentColumn = 'content';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUsersTable = '''CREATE TABLE IF NOT EXISTS "users" (
//         "id"	INTEGER NOT NULL,
//         "email"	TEXT NOT NULL UNIQUE,
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
// const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "content"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "users"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
