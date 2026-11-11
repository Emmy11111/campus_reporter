import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_tile.dart';
import '../../widgets/stat_card.dart';
import '../reports/incident_detail_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key, required this.onReviewSubmitted});

  final VoidCallback onReviewSubmitted;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final incidents = context.watch<IncidentProvider>();

    if (user == null || !user.isStaff) return const SizedBox.shrink();

    final total = incidents.all.length;
    final awaiting = incidents.all
        .where((incident) => incident.status == IncidentStatus.submitted)
        .take(5)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Staff Dashboard',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, ${user.name.split(' ').first}',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Text(
                  user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Reports',
                  value: total,
                  icon: Icons.description_rounded,
                  color: AppTheme.primary,
                  background: const Color(0xFFF1EEFF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Submitted',
                  value: incidents.count(IncidentStatus.submitted),
                  icon: Icons.error_rounded,
                  color: const Color(0xFFE5484D),
                  background: const Color(0xFFFFEAEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'In Progress',
                  value: incidents.count(IncidentStatus.inProgress),
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF2F6BFF),
                  background: const Color(0xFFE8F1FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Resolved',
                  value: incidents.count(IncidentStatus.resolved),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF1E8E4E),
                  background: const Color(0xFFE3F6EA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Reports by category',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: IncidentCategory.values.map((category) {
                final count = incidents.countCategory(category);
                final ratio = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(category.icon, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: Text(
                          category.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFEDE9FF),
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Awaiting review',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: onReviewSubmitted,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (incidents.loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (awaiting.isEmpty)
            const EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'All caught up',
              message: 'There are no submitted reports waiting for review.',
            )
          else
            ...awaiting.map(
              (incident) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: IncidentTile(
                  incident: incident,
                  onTap: () => IncidentDetailScreen.open(context, incident.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}