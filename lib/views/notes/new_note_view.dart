import 'package:flutter/material.dart';
import 'package:zynotes/services/auth/auth_service.dart';
import 'package:zynotes/services/crud/notes_service.dart';
import 'package:zynotes/utilities/progress_indicator.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final content = _textController.text;
    await _notesService.updateNote(
      note: note,
      content: content,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _saveOrDeleteOnDispose() async {
    final note = _note;
    final content = _textController.text;
    if (content.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    } else if (note != null && content.isNotEmpty) {
      await _notesService.updateNote(note: note, content: content);
    }
  }

  @override
  void dispose() {
    _saveOrDeleteOnDispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNotes;
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Start typing your note...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(.35)),
                  border: InputBorder.none,
                ),
              );
            default:
              return Center(child: ActivityIndicator.indicator);
          }
        },
      ),
    );
  }
}
