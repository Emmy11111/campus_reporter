import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/enums.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import 'filter_pill.dart';
import 'loading_button.dart';

class StatusUpdatePanel extends StatefulWidget {
  const StatusUpdatePanel({super.key, required this.incident});

  final Incident incident;

  @override
  State<StatusUpdatePanel> createState() => _StatusUpdatePanelState();
}

class _StatusUpdatePanelState extends State<StatusUpdatePanel> {
  late IncidentStatus _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.incident.status;
  }

  @override
  void didUpdateWidget(covariant StatusUpdatePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incident.status != widget.incident.status) {
      _selected = widget.incident.status;
    }
  }

  Future<void> _save() async {
    final staff = context.read<AuthProvider>().user;
    if (staff == null || !staff.isStaff) return;

    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      await provider.updateStatus(
        incidentId: widget.incident.id,
        status: _selected,
        staffName: staff.name,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('Status updated to ${_selected.label}')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not update the status.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unchanged = _selected == widget.incident.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update status',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: IncidentStatus.values
                .map(
                  (status) => FilterPill(
                    label: status.label,
                    selected: _selected == status,
                    onTap: () => setState(() => _selected = status),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          LoadingButton(
            label: 'Save status',
            loading: _saving,
            onPressed: unchanged ? null : _save,
          ),
        ],
      ),
    );
  }
}