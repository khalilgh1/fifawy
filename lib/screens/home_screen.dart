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

  void _openFilters() async {
    final updatedCriteria = await FilterBottomSheet.show(
      context: context,
      initialCriteria: _currentCriteria,
      competitions: widget.dataService.competitions,
      eligibleCount: widget.dataService.getEligibleTeams(_currentCriteria).length,
      onApply: (applied) {
        setState(() {
          _currentCriteria = applied;
        });
      },
    );

    if (updatedCriteria != null && mounted) {
      setState(() {
        _currentCriteria = updatedCriteria;
      });
    }
  }

  void _generateAndNavigate(FilterCriteria criteria) {
    setState(() {
      _currentCriteria = criteria;
    });

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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 12),
            const Text(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Teams Loaded',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.dataService.teams.length}',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Competitions',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.dataService.competitions.length}',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
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
      ),
    );
  }

  String? get _currentCompName {
    if (_currentCriteria.competitionId == null) return null;
    return widget.dataService
        .getCompetitionById(_currentCriteria.competitionId!)
        ?.name;
  }

  @override
  Widget build(BuildContext context) {
    final eligibleCount = widget.dataService.getEligibleTeams(_currentCriteria).length;

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
              // Pitch visual card
              const PitchPlaceholder(height: 165),

              const SizedBox(height: 24),

              // Title and Subtitle
              Center(
                child: Column(
                  children: [
                    Text(
                      'Ready for your next\nmatch?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate two teams and start playing.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Active filter chips (if customized)
              if (!_currentCriteria.isDefault) ...[
                Center(
                  child: ActiveFilterChips(
                    criteria: _currentCriteria,
                    competitionName: _currentCompName,
                    onRemoveFilter: (key) {
                      setState(() {
                        if (key == 'type') {
                          _currentCriteria = _currentCriteria.copyWith(
                            teamType: TeamTypeFilter.all,
                          );
                        } else if (key == 'competition') {
                          _currentCriteria = _currentCriteria.copyWith(
                            clearCompetition: true,
                          );
                        } else if (key == 'stars') {
                          _currentCriteria = _currentCriteria.copyWith(
                            minStars: 0.0,
                          );
                        }
                      });
                    },
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
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

              // Filter Customizer Link
              Center(
                child: TextButton.icon(
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(
                    _currentCriteria.isDefault
                        ? 'Filter teams ($eligibleCount available)'
                        : 'Change filters ($eligibleCount available)',
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

              // QUICK PLAY Section Header
              const Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: AppColors.accentGreen,
                    size: 20,
                  ),
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
              ),

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
                  QuickPlayCard(
                    title: 'ALL TEAMS',
                    icon: Icons.sports_soccer_rounded,
                    criteria: FilterCriteria.allTeams,
                    isSelected: _currentCriteria == FilterCriteria.allTeams,
                    onTap: () => _generateAndNavigate(FilterCriteria.allTeams),
                  ),
                  QuickPlayCard(
                    title: 'CLUBS',
                    icon: Icons.shield_rounded,
                    criteria: FilterCriteria.clubsOnly,
                    isSelected: _currentCriteria == FilterCriteria.clubsOnly,
                    onTap: () => _generateAndNavigate(FilterCriteria.clubsOnly),
                  ),
                  QuickPlayCard(
                    title: 'NATIONAL TEAMS',
                    icon: Icons.flag_rounded,
                    criteria: FilterCriteria.nationalTeamsOnly,
                    isSelected:
                        _currentCriteria == FilterCriteria.nationalTeamsOnly,
                    onTap: () => _generateAndNavigate(
                        FilterCriteria.nationalTeamsOnly),
                  ),
                  QuickPlayCard(
                    title: '4*+ CLUBS',
                    icon: Icons.star_rounded,
                    criteria: FilterCriteria.topClubs,
                    isSelected: _currentCriteria == FilterCriteria.topClubs,
                    onTap: () => _generateAndNavigate(FilterCriteria.topClubs),
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
