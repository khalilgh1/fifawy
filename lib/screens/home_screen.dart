import 'package:flutter/material.dart';
import '../models/filter_criteria.dart';
import '../models/matchup.dart';
import '../services/team_data_service.dart';
import '../services/random_match_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pitch_placeholder.dart';
import '../widgets/quick_play_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/active_filter_chips.dart';
import 'matchup_screen.dart';

// Presets list — constant, computed once
const _quickPlayPresets = [
  (
    title: 'ALL TEAMS',
    icon: Icons.sports_soccer_rounded,
    criteria: FilterCriteria.allTeams,
  ),
  (
    title: 'CLUBS',
    icon: Icons.shield_rounded,
    criteria: FilterCriteria.clubsOnly,
  ),
  (
    title: 'NATIONAL TEAMS',
    icon: Icons.flag_rounded,
    criteria: FilterCriteria.nationalTeamsOnly,
  ),
  (
    title: '4*+ CLUBS',
    icon: Icons.star_rounded,
    criteria: FilterCriteria.topClubs,
  ),
];

class HomeScreen extends StatefulWidget {
  final TeamDataService dataService;
  final RandomMatchService matchService;

  const HomeScreen({
    super.key,
    required this.dataService,
    required this.matchService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterCriteria _currentCriteria = FilterCriteria.allTeams;

  // Cache the last eligible count to avoid recalculating on every build
  int _eligibleCount = 0;
  String? _currentCompName;

  @override
  void initState() {
    super.initState();
    // Compute initial count once data is available
    _refreshDerivedState();
  }

  void _refreshDerivedState() {
    _eligibleCount = widget.dataService.getEligibleTeams(_currentCriteria).length;
    _currentCompName = _currentCriteria.competitionId != null
        ? widget.dataService.getCompetitionById(_currentCriteria.competitionId!)?.name
        : null;
  }

  void _updateCriteria(FilterCriteria criteria) {
    _currentCriteria = criteria;
    _refreshDerivedState();
  }

  void _openFilters() async {
    final updatedCriteria = await FilterBottomSheet.show(
      context: context,
      initialCriteria: _currentCriteria,
      competitions: widget.dataService.competitions,
      eligibleCount: _eligibleCount,
      onApply: (applied) {
        setState(() {
          _updateCriteria(applied);
        });
      },
    );

    if (updatedCriteria != null && mounted) {
      setState(() {
        _updateCriteria(updatedCriteria);
      });
    }
  }

  void _generateAndNavigate(FilterCriteria criteria) {
    // Update criteria without an extra setState if same
    if (criteria != _currentCriteria) {
      setState(() {
        _updateCriteria(criteria);
      });
    }

    final eligible = widget.dataService.getEligibleTeams(criteria);
    Matchup? initialMatchup;

    if (eligible.length >= 2) {
      initialMatchup = widget.matchService.generateMatchup(eligible);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchupScreen(
          initialMatchup: initialMatchup,
          initialCriteria: criteria,
          competitions: widget.dataService.competitions,
          getEligibleCount: (crit) =>
              widget.dataService.getEligibleTeams(crit).length,
          onGenerateMatchup: (crit, {previous}) {
            final pool = widget.dataService.getEligibleTeams(crit);
            return widget.matchService.generateMatchup(
              pool,
              previousHome: previous?.homeTeam,
              previousAway: previous?.awayTeam,
            );
          },
        ),
      ),
    );
  }

  void _removeFilter(String key) {
    setState(() {
      if (key == 'type') {
        _updateCriteria(_currentCriteria.copyWith(teamType: TeamTypeFilter.all));
      } else if (key == 'competition') {
        _updateCriteria(_currentCriteria.copyWith(clearCompetition: true));
      } else if (key == 'stars') {
        _updateCriteria(_currentCriteria.copyWith(minStars: 0.0));
      }
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => _InfoDialog(
        teamCount: widget.dataService.teams.length,
        competitionCount: widget.dataService.competitions.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'FIFAWY',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: _showInfoDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pitch visual card — const, does not depend on state
              const PitchPlaceholder(height: 165),

              const SizedBox(height: 24),

              // Title and Subtitle — const subtree
              const _HomeHeroText(),

              const SizedBox(height: 16),

              // Active filter chips
              if (!_currentCriteria.isDefault) ...[
                Center(
                  child: ActiveFilterChips(
                    criteria: _currentCriteria,
                    competitionName: _currentCompName,
                    onRemoveFilter: _removeFilter,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Main GENERATE MATCH Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generateAndNavigate(_currentCriteria),
                  icon: const Icon(Icons.bolt_rounded, size: 24),
                  label: const Text('GENERATE MATCH'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter link with current count
              Center(
                child: TextButton.icon(
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(
                    _currentCriteria.isDefault
                        ? 'Filter teams ($_eligibleCount available)'
                        : 'Change filters ($_eligibleCount available)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const _QuickPlayHeader(),

              const SizedBox(height: 14),

              // 2x2 Grid of Quick Play Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  for (final preset in _quickPlayPresets)
                    QuickPlayCard(
                      title: preset.title,
                      icon: preset.icon,
                      criteria: preset.criteria,
                      isSelected: _currentCriteria == preset.criteria,
                      onTap: () => _generateAndNavigate(preset.criteria),
                    ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Static subtrees extracted as const widgets ─────────────────────────────

class _HomeHeroText extends StatelessWidget {
  const _HomeHeroText();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text(
            'Ready for your next\nmatch?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              height: 1.15,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Generate two teams and start playing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPlayHeader extends StatelessWidget {
  const _QuickPlayHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.bolt_rounded, color: AppColors.accentGreen, size: 20),
        SizedBox(width: 6),
        Text(
          'QUICK PLAY',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _InfoDialog extends StatelessWidget {
  final int teamCount;
  final int competitionCount;

  const _InfoDialog({
    required this.teamCount,
    required this.competitionCount,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      title: const Row(
        children: [
          _InfoIconBadge(),
          SizedBox(width: 12),
          Text(
            'FIFAWY',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Random 1v1 matchup generator for EA SPORTS FC 26 matches.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Total Teams Loaded', value: '$teamCount'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Competitions', value: '$competitionCount'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'CLOSE',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoIconBadge extends StatelessWidget {
  const _InfoIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.sports_soccer_rounded,
        color: AppColors.accentGreen,
        size: 24,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
