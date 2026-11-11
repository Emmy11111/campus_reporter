import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../report_form/report_form_screen.dart';
import '../reports/reports_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSeeAll: () => _select(1),
            onReport: () => ReportFormScreen.open(context),
          ),
          const ReportsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onSelect: _select,
        onReport: () => ReportFormScreen.open(context),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onSelect,
    required this.onReport,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 92,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 68,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        selected: index == 0,
                        onTap: () => onSelect(0),
                      ),
                      _NavItem(
                        icon: Icons.description_outlined,
                        label: 'Reports',
                        selected: index == 1,
                        onTap: () => onSelect(1),
                      ),
                      const Expanded(child: SizedBox()),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        selected: index == 2,
                        onTap: () => onSelect(2),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0.25, 1),
                child: GestureDetector(
                  onTap: onReport,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x596C47FF),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: bottomInset, color: Colors.white),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : AppTheme.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}