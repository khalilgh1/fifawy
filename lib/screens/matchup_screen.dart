import 'package:flutter/material.dart';
import '../models/matchup.dart';
import '../models/filter_criteria.dart';
import '../models/competition.dart';
import '../theme/app_theme.dart';
import '../widgets/team_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'empty_matchup_view.dart';

class MatchupScreen extends StatefulWidget {
  final Matchup? initialMatchup;
  final FilterCriteria initialCriteria;
  final List<Competition> competitions;
  final Matchup Function(FilterCriteria criteria, {Matchup? previous}) onGenerateMatchup;
  final int Function(FilterCriteria criteria) getEligibleCount;

  const MatchupScreen({
    super.key,
    required this.initialMatchup,
    required this.initialCriteria,
    required this.competitions,
    required this.onGenerateMatchup,
    required this.getEligibleCount,
  });

  @override
  State<MatchupScreen> createState() => _MatchupScreenState();
}

class _MatchupScreenState extends State<MatchupScreen>
    with SingleTickerProviderStateMixin {
  late FilterCriteria _criteria;
  Matchup? _matchup;
  bool _isRerolling = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideHomeAnim;
  late Animation<Offset> _slideAwayAnim;

  @override
  void initState() {
    super.initState();
    _criteria = widget.initialCriteria;
    _matchup = widget.initialMatchup;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideHomeAnim = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _slideAwayAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reroll() {
    final eligible = widget.getEligibleCount(_criteria);
    if (eligible < 2) {
      setState(() {
        _matchup = null;
      });
      return;
    }

    setState(() {
      _isRerolling = true;
    });

    _animController.reset();
    final newMatchup = widget.onGenerateMatchup(_criteria, previous: _matchup);

    setState(() {
      _matchup = newMatchup;
      _isRerolling = false;
    });

    _animController.forward();
  }

  void _openFilterSheet() async {
    final newCriteria = await FilterBottomSheet.show(
      context: context,
      initialCriteria: _criteria,
      competitions: widget.competitions,
      eligibleCount: widget.getEligibleCount(_criteria),
      onApply: (updated) {
        setState(() {
          _criteria = updated;
        });
        _reroll();
      },
    );

    if (newCriteria != null && mounted) {
      setState(() {
        _criteria = newCriteria;
      });
      _reroll();
    }
  }

  void _handleRemoveFilterTag(String key) {
    setState(() {
      if (key == 'type') {
        _criteria = _criteria.copyWith(teamType: TeamTypeFilter.all);
      } else if (key == 'competition') {
        _criteria = _criteria.copyWith(clearCompetition: true);
      } else if (key == 'stars') {
        _criteria = _criteria.copyWith(minStars: 0.0);
      }
    });
    _reroll();
  }

  void _resetFilters() {
    setState(() {
      _criteria = FilterCriteria.allTeams;
    });
    _reroll();
  }

  String? get _currentCompName {
    if (_criteria.competitionId == null) return null;
    return widget.competitions
        .where((c) => c.id == _criteria.competitionId)
        .map((c) => c.name)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _matchup != null ? 'YOUR MATCHUP' : 'FIFAWY',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: !_criteria.isDefault,
              backgroundColor: AppColors.accentGreen,
              smallSize: 8,
              child: const Icon(Icons.tune_rounded, size: 22),
            ),
            onPressed: _openFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _matchup == null
            ? EmptyMatchupView(
                criteria: _criteria,
                competitionName: _currentCompName,
                onAdjustFilters: _openFilterSheet,
                onResetFilters: _resetFilters,
                onRemoveFilter: _handleRemoveFilterTag,
              )
            : _buildMatchupContent(),
      ),
    );
  }

  Widget _buildMatchupContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Home Team Card
                  SlideTransition(
                    position: _slideHomeAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: TeamCard(
                        team: _matchup!.homeTeam,
                        side: MatchupSide.home,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // VS Divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.surfaceBorder.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surfaceBorder.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Away Team Card
                  SlideTransition(
                    position: _slideAwayAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: TeamCard(
                        team: _matchup!.awayTeam,
                        side: MatchupSide.away,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reroll Primary Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isRerolling ? null : _reroll,
            icon: const Icon(Icons.refresh_rounded, size: 22),
            label: const Text('REROLL'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // New Matchup / Filter Settings Secondary Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.widgets_outlined, size: 20),
            label: const Text('NEW MATCHUP'),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.surfaceBorder, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
