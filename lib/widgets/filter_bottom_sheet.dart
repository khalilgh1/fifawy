import 'package:flutter/material.dart';
import '../models/competition.dart';
import '../models/filter_criteria.dart';
import '../theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterCriteria initialCriteria;
  final List<Competition> competitions;
  final int eligibleCount;
  final ValueChanged<FilterCriteria> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.competitions,
    required this.eligibleCount,
    required this.onApply,
  });

  static Future<FilterCriteria?> show({
    required BuildContext context,
    required FilterCriteria initialCriteria,
    required List<Competition> competitions,
    required int eligibleCount,
    required ValueChanged<FilterCriteria> onApply,
  }) {
    return showModalBottomSheet<FilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialCriteria: initialCriteria,
        competitions: competitions,
        eligibleCount: eligibleCount,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TeamTypeFilter _selectedType;
  late String? _selectedCompetitionId;
  late double _selectedMinStars;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialCriteria.teamType;
    _selectedCompetitionId = widget.initialCriteria.competitionId;
    _selectedMinStars = widget.initialCriteria.minStars;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = TeamTypeFilter.all;
      _selectedCompetitionId = null;
      _selectedMinStars = 0.0;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _applyFilters() {
    final newCriteria = FilterCriteria(
      teamType: _selectedType,
      competitionId: _selectedCompetitionId,
      minStars: _selectedMinStars,
    );
    widget.onApply(newCriteria);
    Navigator.of(context).pop(newCriteria);
  }

  List<Competition> get _filteredCompetitions {
    // Filter by team type relevance if applicable
    var list = widget.competitions;
    if (_selectedType == TeamTypeFilter.nationalTeams) {
      list = list.where((c) => c.isInternational).toList();
    } else if (_selectedType == TeamTypeFilter.clubs) {
      list = list.where((c) => !c.isInternational).toList();
    }

    if (_searchQuery.isEmpty) return list;
    return list.where((c) {
      final nameMatches = c.name.toLowerCase().contains(_searchQuery);
      final idMatches = c.id.toLowerCase().contains(_searchQuery);
      return nameMatches || idMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceElevated,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 1),

            // Filter Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TEAM TYPE
                    _buildSectionHeader('TEAM TYPE'),
                    const SizedBox(height: 10),
                    _buildTeamTypeSelector(),

                    const SizedBox(height: 24),

                    // 2. LEAGUE / COMPETITION
                    _buildSectionHeader('LEAGUE / COMPETITION'),
                    const SizedBox(height: 10),
                    _buildCompetitionSearchBar(),
                    const SizedBox(height: 12),
                    _buildCompetitionChips(),

                    const SizedBox(height: 24),

                    // 3. MINIMUM RATING
                    _buildSectionHeader('MINIMUM RATING'),
                    const SizedBox(height: 8),
                    _buildStarPreview(),
                    const SizedBox(height: 12),
                    _buildStarRatingSelector(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('APPLY FILTERS'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentGreen,
                    ),
                    child: const Text(
                      'RESET FILTERS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTeamTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TeamTypeFilter.values.map((type) {
          final isSelected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  // If switching to National Teams and competition was club, or vice versa, adjust safely
                  if (_selectedCompetitionId != null) {
                    final comp = widget.competitions
                        .where((c) => c.id == _selectedCompetitionId)
                        .firstOrNull;
                    if (comp != null) {
                      if (type == TeamTypeFilter.nationalTeams &&
                          !comp.isInternational) {
                        _selectedCompetitionId = null;
                      } else if (type == TeamTypeFilter.clubs &&
                          comp.isInternational) {
                        _selectedCompetitionId = null;
                      }
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnAccent
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompetitionSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search league or competition',
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCompetitionChips() {
    final comps = _filteredCompetitions;
    final isAllSelected = _selectedCompetitionId == null || _selectedCompetitionId!.isEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "All" chip
        _buildCompChip(
          label: 'All',
          isSelected: isAllSelected,
          onTap: () {
            setState(() {
              _selectedCompetitionId = null;
            });
          },
        ),

        // List of competitions
        ...comps.map((comp) {
          final isSelected = _selectedCompetitionId == comp.id;
          return _buildCompChip(
            label: comp.name,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCompetitionId = null;
                } else {
                  _selectedCompetitionId = comp.id;
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildCompChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGreen : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGreen
                : AppColors.surfaceBorder,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnAccent : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStarPreview() {
    final filledStars = _selectedMinStars.toInt();
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < filledStars;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            Icons.star_rounded,
            size: 24,
            color: isFilled ? AppColors.starGold : AppColors.starInactive,
          ),
        );
      }),
    );
  }

  Widget _buildStarRatingSelector() {
    final ratings = [
      (label: '1★', value: 1.0),
      (label: '2★', value: 2.0),
      (label: '3★', value: 3.0),
      (label: '4★', value: 4.0),
      (label: '5★', value: 5.0),
    ];

    return Row(
      children: ratings.map((r) {
        final isSelected = _selectedMinStars == r.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // Toggle star rating (tapping same star again deselects to any)
                  if (_selectedMinStars == r.value) {
                    _selectedMinStars = 0.0;
                  } else {
                    _selectedMinStars = r.value;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGreen
                        : AppColors.surfaceBorder,
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  r.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnAccent
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
