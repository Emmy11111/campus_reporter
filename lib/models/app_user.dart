import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/enums.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String department;
  final UserRole role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department = '',
    required this.createdAt,
  });

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        department: map['department'] ?? '',
        role: UserRole.fromString(map['role']),
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'department': department,
        'role': role.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}