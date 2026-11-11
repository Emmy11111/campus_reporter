import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/incident_tile.dart';
import 'incident_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<IncidentProvider>().query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final isStaff = context.watch<AuthProvider>().user?.isStaff ?? false;
    final results = provider.filtered;

    if (_searchController.text != provider.query) {
      _searchController.text = provider.query;
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStaff ? 'All Reports' : 'Campus Reports',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (provider.hasActiveFilters)
                  TextButton(
                    onPressed: provider.clearFilters,
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by title, location or category',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: provider.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => provider.setQuery(''),
                      ),
              ),
            ),
          ),
          if (!isStaff) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  FilterPill(
                    label: 'All reports',
                    selected: !provider.mineOnly,
                    onTap: () => provider.setMineOnly(false),
                  ),
                  const SizedBox(width: 8),
                  FilterPill(
                    label: 'My reports',
                    selected: provider.mineOnly,
                    onTap: () => provider.setMineOnly(true),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _pill(
                  'All',
                  provider.statusFilter == null,
                  () => provider.setStatusFilter(null),
                ),
                ...IncidentStatus.values.map(
                  (status) => _pill(
                    status.label,
                    provider.statusFilter == status,
                    () => provider.setStatusFilter(status),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _pill(
                  'Any category',
                  provider.categoryFilter == null,
                  () => provider.setCategoryFilter(null),
                ),
                ...IncidentCategory.values.map(
                  (category) => _pill(
                    category.label,
                    provider.categoryFilter == category,
                    () => provider.setCategoryFilter(category),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Text(
              '${results.length} ${results.length == 1 ? 'report' : 'reports'}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
          Expanded(child: _buildList(provider, results)),
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

  Widget _buildList(IncidentProvider provider, List results) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: provider.error,
      );
    }
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No reports found',
        message: provider.hasActiveFilters
            ? 'Try changing your search or filters.'
            : 'Reports will appear here once submitted.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final incident = results[index];
        return IncidentTile(
          incident: incident,
          onTap: () => IncidentDetailScreen.open(context, incident.id),
        );
      },
    );
  }
}