import 'package:flutter/material.dart';
import 'package:zynotes/services/cloud/cloud_notes.dart';
import 'package:zynotes/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNotes note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNotes> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          // final reversedIndex = notes.length - 1 - index;
          final note = notes.elementAt(index);

          if (note.title.isNotEmpty && note.content.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: Colors.white.withOpacity(.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                onTap: () {
                  onTap(note);
                },
                title: Text(
                  note.title,
                  maxLines: 2,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  note.content,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 16),
                  maxLines: 3,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) {
                        onDeleteNote(note);
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    )),
              ),
            );
          } else if (note.title.isNotEmpty && note.content.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: Colors.white.withOpacity(.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                onTap: () {
                  onTap(note);
                },
                title: Text(
                  note.title,
                  maxLines: 2,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                trailing: IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) {
                        onDeleteNote(note);
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    )),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: Colors.white.withOpacity(.3),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                onTap: () {
                  onTap(note);
                },
                title: Text(
                  note.content,
                  maxLines: 2,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                trailing: IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete) {
                        onDeleteNote(note);
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    )),
              ),
            );
          }
        });
  }
}
