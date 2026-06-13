import 'package:flutter/material.dart';

import '../game/case_model.dart';

class CaseGrid extends StatelessWidget {
  const CaseGrid({
    super.key,
    required this.cases,
    required this.onCaseTap,
  });

  final List<GameCase> cases;
  final ValueChanged<GameCase> onCaseTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cases.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final gameCase = cases[index];
        final style = _styleFor(context, gameCase.status);

        return Material(
          color: style.background,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: gameCase.status == CaseStatus.opened
                ? null
                : () => onCaseTap(gameCase),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: style.border, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(style.icon, color: style.foreground, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    '${gameCase.number}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: style.foreground,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _CaseStyle _styleFor(BuildContext context, CaseStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case CaseStatus.selected:
        return _CaseStyle(
          background: const Color(0xFFE7F6EF),
          foreground: scheme.primary,
          border: scheme.primary,
          icon: Icons.business_center,
        );
      case CaseStatus.opened:
        return const _CaseStyle(
          background: Color(0xFFE8ECEA),
          foreground: Color(0xFF7C8782),
          border: Color(0xFFD0D7D3),
          icon: Icons.lock_open,
        );
      case CaseStatus.closed:
        return const _CaseStyle(
          background: Color(0xFF123B32),
          foreground: Colors.white,
          border: Color(0xFF0B2B24),
          icon: Icons.work,
        );
    }
  }
}

class _CaseStyle {
  const _CaseStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
}
