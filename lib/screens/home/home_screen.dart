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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll, required this.onReport});

  final VoidCallback onSeeAll;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final incidents = context.watch<IncidentProvider>();
    final mine = incidents.mine;
    final recent = mine.take(3).toList();
    final firstName = (user?.name ?? '').split(' ').first;

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
                    Text(
                      'Hello, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Help make our campus safer.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Text(
                      'Report issues and track their resolution.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Text(
                  firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
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
          _ReportBanner(onTap: onReport),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Report Summary', onSeeAll: onSeeAll),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'My Reports',
                  value: mine.length,
                  icon: Icons.description_rounded,
                  color: AppTheme.primary,
                  background: const Color(0xFFF1EEFF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'In Progress',
                  value: incidents.count(
                    IncidentStatus.inProgress,
                    mineOnly: true,
                  ),
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF2F6BFF),
                  background: const Color(0xFFE8F1FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Resolved',
                  value: incidents.count(
                    IncidentStatus.resolved,
                    mineOnly: true,
                  ),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF1E8E4E),
                  background: const Color(0xFFE3F6EA),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Submitted',
                  value: incidents.count(
                    IncidentStatus.submitted,
                    mineOnly: true,
                  ),
                  icon: Icons.error_rounded,
                  color: const Color(0xFFE5484D),
                  background: const Color(0xFFFFEAEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Recent Reports', onSeeAll: onSeeAll),
          const SizedBox(height: 12),
          if (incidents.loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (incidents.error != null)
            EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Something went wrong',
              message: incidents.error,
            )
          else if (recent.isEmpty)
            const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No reports yet',
              message: 'Tap Report an Issue to submit your first report.',
            )
          else
            ...recent.map(
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

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B6CFF), Color(0xFF6C47FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -6,
            top: -4,
            child: Icon(
              Icons.apartment_rounded,
              size: 110,
              color: Color(0x33FFFFFF),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'See an issue\non campus?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Report it and help improve\nour learning environment.',
                style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 13),
              ),
              const SizedBox(height: 18),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.primary,
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Report an Issue',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        GestureDetector(
          onTap: onSeeAll,
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
    );
  }
}