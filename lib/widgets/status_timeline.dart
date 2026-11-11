import 'package:flutter/material.dart';

import '../core/constants/enums.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/incident.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  DateTime? _timeFor(IncidentStatus status) {
    DateTime? found;
    for (final entry in incident.history) {
      if (entry.status == status) found = entry.at;
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final steps = IncidentStatus.values;
    final currentIndex = incident.status.index;
    final children = <Widget>[];

    for (var i = 0; i < steps.length; i++) {
      children.add(
        _TimelineStep(
          label: steps[i].label,
          date: i <= currentIndex ? _timeFor(steps[i]) : null,
          completed: i < currentIndex,
          current: i == currentIndex,
        ),
      );
      if (i < steps.length - 1) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Container(
                height: 2,
                color: i < currentIndex
                    ? AppTheme.primary
                    : const Color(0xFFDAD7EC),
              ),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.date,
    required this.completed,
    required this.current,
  });

  final String label;
  final DateTime? date;
  final bool completed;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final reached = completed || current;

    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached ? AppTheme.primary : Colors.white,
              border: Border.all(
                color: reached ? AppTheme.primary : const Color(0xFFDAD7EC),
                width: 2,
              ),
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.circle,
              size: completed ? 16 : 8,
              color: reached ? Colors.white : const Color(0xFFDAD7EC),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: reached ? AppTheme.primary : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date == null ? '—' : Formatters.shortDate(date!),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}