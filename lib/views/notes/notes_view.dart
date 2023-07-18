// ignore_for_file: use_build_context_synchronously

import 'package:zynotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:zynotes/constants/routes.dart';
import 'package:zynotes/enums/menu_action.dart';
import 'package:zynotes/services/cloud/cloud_notes.dart';
import 'package:zynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:zynotes/utilities/dialogs/logout_dialog.dart';
import 'package:zynotes/utilities/progress_indicator.dart';
import 'package:zynotes/views/notes/notes_list_view.dart';

//USER HOME VIEW

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Notes'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createUpdateNoteView);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Log Out')),
              ];
            }, onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    showDialog(
                      context: context,
                      builder: (context) => ActivityIndicator.indicator,
                    );
                    await AuthService.firebase().signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginView, (route) => false);
                  }
              }
            })
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StreamBuilder(
                stream: _notesService.allNotes(ownerUserId: userId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as Iterable<CloudNotes>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(
                                documentId: note.documentId);
                          },
                          onTap: (note) async {
                            Navigator.of(context).pushNamed(
                              createUpdateNoteView,
                              arguments: note,
                            );
                          },
                        );
                      } else {
                        return Center(child: ActivityIndicator.indicator);
                      }
                    default:
                      return Center(child: ActivityIndicator.indicator);
                  }
                })));
  }
}
