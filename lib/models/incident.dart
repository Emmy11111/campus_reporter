import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/enums.dart';

class StatusEntry {
  final IncidentStatus status;
  final DateTime at;
  final String by;

  StatusEntry({required this.status, required this.at, required this.by});

  factory StatusEntry.fromMap(Map<String, dynamic> map) => StatusEntry(
        status: IncidentStatus.fromString(map['status']),
        at: (map['at'] as Timestamp).toDate(),
        by: map['by'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'at': Timestamp.fromDate(at),
        'by': by,
      };
}

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String? imageUrl;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusEntry> history;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    this.imageUrl,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return Incident(
      id: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: IncidentCategory.fromString(map['category']),
      location: map['location'] ?? '',
      status: IncidentStatus.fromString(map['status']),
      imageUrl: map['imageUrl'],
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      history: ((map['history'] ?? []) as List)
          .map((e) => StatusEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
        'status': status.name,
        'imageUrl': imageUrl,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'history': history.map((h) => h.toMap()).toList(),
      };
}