import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/incident_tile.dart';
import '../../widgets/stat_card.dart';
import '../reports/incident_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  IncidentStatus? _filter;

  Future<void> _confirmSignOut() async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final incidents = context.watch<IncidentProvider>();
    if (user == null) return const SizedBox.shrink();

    final mine = incidents.mine;
    final visible = _filter == null
        ? mine
        : mine.where((incident) => incident.status == _filter).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user.isStaff ? 'Profile' : 'My Reports',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: _confirmSignOut,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign out',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.isStaff ? 'Staff' : 'Student',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (user.department.isNotEmpty)
                        _infoRow(Icons.school_outlined, user.department),
                      _infoRow(Icons.mail_outline_rounded, user.email),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!user.isStaff) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Reports',
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
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _pill('All', _filter == null, () {
                    setState(() => _filter = null);
                  }),
                  ...IncidentStatus.values.map(
                    (status) => _pill(status.label, _filter == status, () {
                      setState(() => _filter = status);
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (visible.isEmpty)
              const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No reports here',
                message: 'Reports you submit will appear in this list.',
              )
            else
              ...visible.map(
                (incident) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IncidentTile(
                    incident: incident,
                    onTap: () =>
                        IncidentDetailScreen.open(context, incident.id),
                  ),
                ),
              ),
          ] else ...[
            const SizedBox(height: 24),
            const EmptyState(
              icon: Icons.verified_user_outlined,
              title: 'Authorized staff account',
              message:
                  'You can review all reports and update their status from the Dashboard and Reports tabs.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterPill(label: label, selected: selected, onTap: onTap),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}