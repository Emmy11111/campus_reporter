import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_tile.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/status_update_panel.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  static Future<void> open(BuildContext context, String incidentId) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentDetailScreen(incidentId: incidentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incident = context.select<IncidentProvider, Incident?>(
      (provider) => provider.byId(incidentId),
    );
    final isStaff = context.select<AuthProvider, bool>(
      (auth) => auth.user?.isStaff ?? false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: incident == null
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Report not found',
              message: 'This report may have been removed.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IncidentThumbnail(incident: incident, size: 72),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incident.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${incident.category.label} · ${incident.location}',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusChip(status: incident.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _metaRow(
                        Icons.calendar_today_outlined,
                        'Submitted on ${Formatters.fullDate(incident.createdAt)}',
                      ),
                      const SizedBox(height: 8),
                      _metaRow(
                        Icons.person_outline_rounded,
                        'Reported by ${incident.reporterName}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Timeline',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatusTimeline(incident: incident),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        incident.description,
                        style: const TextStyle(height: 1.5, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (incident.imageUrl != null) ...[
                  const SizedBox(height: 14),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attached Photo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: incident.imageUrl!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) =>
                                const SizedBox(
                              height: 220,
                              child: Center(
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isStaff) ...[
                  const SizedBox(height: 14),
                  StatusUpdatePanel(incident: incident),
                ],
              ],
            ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}