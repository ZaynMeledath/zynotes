import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zynotes/services/auth/auth_service.dart';
import 'package:zynotes/services/cloud/cloud_notes.dart';
import 'package:zynotes/extensions/get_arguments.dart';
import 'package:zynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:zynotes/utilities/progress_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNotes? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    super.initState();
  }

  Future<CloudNotes> createOrGetNote(BuildContext context) async {
    final existingNote = context.getArgument<CloudNotes>();

    if (existingNote != null) {
      _note = existingNote;
      _titleController.text = existingNote.title;
      _contentController.text = existingNote.content;
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text;
    final content = _contentController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      title: title,
      content: content,
    );
  }

  void _setupTextControllerListener() {
    _contentController.removeListener(_textControllerListener);
    _contentController.addListener(_textControllerListener);
  }

  void _saveOrDeleteOnDispose() async {
    final note = _note;
    final title = _titleController.text;
    final content = _contentController.text;
    if (note != null && (content.isNotEmpty || title.isNotEmpty)) {
      await _notesService.updateNote(
        documentId: note.documentId,
        title: title,
        content: content,
      );
    } else if (note != null && (content.isEmpty && title.isEmpty)) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  @override
  void dispose() {
    _saveOrDeleteOnDispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('New Note'), centerTitle: true, actions: [
        IconButton(
            onPressed: () {
              final title = _titleController.text;
              final content = _contentController.text;
              final textList = [title, content];
              final emptyCheck = title.isNotEmpty && content.isNotEmpty;
              final joinedText =
                  emptyCheck ? textList.join('\n\n') : textList.join();
              if (title.isEmpty && content.isEmpty) {
                Fluttertoast.showToast(
                    msg: 'Cannot share empty note',
                    toastLength: Toast.LENGTH_SHORT);
              } else {
                Share.share(joinedText);
              }
            },
            icon: const Icon(Icons.share))
      ]),
      body: FutureBuilder(
        future: createOrGetNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(children: [
                  TextField(
                      controller: _titleController,
                      maxLines: null,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 22,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(.35)),
                        border: InputBorder.none,
                      )),
                  TextField(
                    controller: _contentController,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing your note...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(.35),
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ]),
              );
            default:
              return Center(child: ActivityIndicator.indicator);
          }
        },
      ),
    );
  }
}
