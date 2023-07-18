import 'package:flutter/foundation.dart';
import 'package:zynotes/services/cloud/cloud_storage_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class CloudNotes {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String content;

  const CloudNotes({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.content,
  });

  CloudNotes.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        content = snapshot.data()[contentFieldName] as String;
}
