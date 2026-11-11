import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/enums.dart';
import '../models/incident.dart';

class IncidentService {
  IncidentService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('incidents');

  String newId() => _collection.doc().id;

  Stream<List<Incident>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Incident.fromDoc).toList());
  }

  Future<void> create(Incident incident) {
    return _collection.doc(incident.id).set(incident.toMap());
  }

  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus status,
    required String staffName,
  }) {
    final entry = StatusEntry(
      status: status,
      at: DateTime.now(),
      by: staffName,
    );
    return _collection.doc(incidentId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
      'history': FieldValue.arrayUnion([entry.toMap()]),
    });
  }
}