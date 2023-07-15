import 'package:flutter/material.dart';
import 'package:zynotes/services/auth/auth_service.dart';
import 'package:zynotes/services/crud/notes_service.dart';
import 'package:zynotes/extensions/get_arguments.dart';
import 'package:zynotes/utilities/progress_indicator.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNotes> createOrGetNote(BuildContext context) async {
    final existingNote = context.getArgument<DatabaseNotes>();

    if (existingNote != null) {
      _note = existingNote;
      _textController.text = existingNote.content;
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
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
    if (note != null && content.isEmpty) {
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
        future: createOrGetNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Start typing your note...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
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
