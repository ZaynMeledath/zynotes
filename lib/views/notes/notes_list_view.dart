import 'package:flutter/material.dart';
import 'package:zynotes/services/crud/notes_service.dart';
import 'package:zynotes/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNotes note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNotes> notes;
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
          final reversedIndex = notes.length - 1 - index;
          final note = notes[reversedIndex];
          return ListTile(
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.content,
              maxLines: 2,
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
                icon: const Icon(Icons.delete)),
          );
        });
  }
}
