import 'package:flutter/material.dart';
import '../models/filter_criteria.dart';
import '../theme/app_theme.dart';

class ActiveFilterChips extends StatelessWidget {
  final FilterCriteria criteria;
  final String? competitionName;
  final Function(String key)? onRemoveFilter;

  const ActiveFilterChips({
    super.key,
    required this.criteria,
    this.competitionName,
    this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (criteria.isDefault) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];

    // Competition tag
    if (criteria.competitionId != null && criteria.competitionId!.isNotEmpty) {
      final name = competitionName ?? criteria.competitionId!;
      chips.add(_buildChip(
        label: name,
        keyName: 'competition',
      ));
    }

    // Stars tag
    if (criteria.minStars > 0.0) {
      final starsStr = criteria.minStars % 1 == 0
          ? '${criteria.minStars.toInt()}★+'
          : '${criteria.minStars}★+';
      chips.add(_buildChip(
        label: starsStr,
        keyName: 'stars',
      ));
    }

    // Team Type tag (if not all)
    if (criteria.teamType != TeamTypeFilter.all) {
      chips.add(_buildChip(
        label: criteria.teamType.label,
        keyName: 'type',
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }

  Widget _buildChip({
    required String label,
    required String keyName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGreenDark.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accentGreenLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          if (onRemoveFilter != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onRemoveFilter!(keyName),
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.accentGreenLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
