import 'package:flutter/material.dart';

enum UserRole {
  student,
  staff;

  static UserRole fromString(String? value) =>
      value == 'staff' ? UserRole.staff : UserRole.student;
}

enum IncidentCategory {
  facilities('Facilities', Icons.apartment_rounded),
  water('Water', Icons.water_drop_outlined),
  electricity('Electricity', Icons.bolt_outlined),
  safety('Safety', Icons.shield_outlined),
  sanitation('Sanitation', Icons.delete_outline_rounded);

  const IncidentCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  static IncidentCategory fromString(String? value) =>
      IncidentCategory.values.firstWhere(
        (c) => c.name == value,
        orElse: () => IncidentCategory.facilities,
      );
}

enum IncidentStatus {
  submitted('Submitted', Color(0xFFFFF1D6), Color(0xFFB26A00)),
  inProgress('In Progress', Color(0xFFEDE9FF), Color(0xFF6C47FF)),
  resolved('Resolved', Color(0xFFE3F6EA), Color(0xFF1E8E4E));

  const IncidentStatus(this.label, this.background, this.foreground);
  final String label;
  final Color background;
  final Color foreground;

  static IncidentStatus fromString(String? value) =>
      IncidentStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => IncidentStatus.submitted,
      );
}