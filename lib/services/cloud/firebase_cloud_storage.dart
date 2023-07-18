import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zynotes/services/cloud/cloud_notes.dart';
import 'package:zynotes/services/cloud/cloud_storage_constants.dart';
import 'package:zynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  FirebaseCloudStorage._sharedInstance();
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  Stream<Iterable<CloudNotes>> allNotes({required ownerUserId}) =>
      notes.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => CloudNotes.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<CloudNotes> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: '',
      contentFieldName: '',
    });

    final fetchedNote = await document.get();
    return CloudNotes(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      title: '',
      content: '',
    );
  }

  Future<Iterable<CloudNotes>> getNotes({required ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
              (value) => value.docs.map((doc) => CloudNotes.fromSnapshot(doc)));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String title,
    required String content,
  }) async {
    try {
      await notes
          .doc(documentId)
          .update({titleFieldName: title, contentFieldName: content});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required documentId}) async {
    try {
      await notes.doc(documentId).delete();
      Fluttertoast.showToast(
        msg: 'Note Removed',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
