import 'package:flutter/material.dart';
import '../models/filter_criteria.dart';
import '../theme/app_theme.dart';
import '../widgets/active_filter_chips.dart';

class EmptyMatchupView extends StatelessWidget {
  final FilterCriteria criteria;
  final String? competitionName;
  final VoidCallback onAdjustFilters;
  final VoidCallback onResetFilters;
  final Function(String key) onRemoveFilter;

  const EmptyMatchupView({
    super.key,
    required this.criteria,
    this.competitionName,
    required this.onAdjustFilters,
    required this.onResetFilters,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Center Icon Badge (Magnifying glass over dark sphere)
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.surfaceElevated,
                  AppColors.surface,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: AppColors.surfaceBorder,
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.search_off_rounded,
                size: 52,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          Text(
            'Not enough teams',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          Text(
            'Try adjusting your filters to\ngenerate a matchup.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
          ),

          const SizedBox(height: 28),

          // Active Filters Tag Header & Chips
          if (!criteria.isDefault) ...[
            const Text(
              'ACTIVE FILTERS',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ActiveFilterChips(
              criteria: criteria,
              competitionName: competitionName,
              onRemoveFilter: onRemoveFilter,
            ),
          ],

          const Spacer(),

          // Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdjustFilters,
              icon: const Icon(Icons.tune_rounded, size: 20),
              label: const Text('ADJUST FILTERS'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onResetFilters,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'RESET FILTERS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
