enum TeamTypeFilter {
  all('All'),
  clubs('Clubs'),
  nationalTeams('National Teams');

  final String label;
  const TeamTypeFilter(this.label);
}

class FilterCriteria {
  final TeamTypeFilter teamType;
  final String? competitionId;
  final double minStars; // 0.0 = Any, 1.0 to 5.0

  const FilterCriteria({
    this.teamType = TeamTypeFilter.all,
    this.competitionId,
    this.minStars = 0.0,
  });

  bool get isDefault =>
      teamType == TeamTypeFilter.all &&
      (competitionId == null || competitionId!.isEmpty) &&
      minStars <= 0.0;

  int get activeFilterCount {
    int count = 0;
    if (teamType != TeamTypeFilter.all) count++;
    if (competitionId != null && competitionId!.isNotEmpty) count++;
    if (minStars > 0.0) count++;
    return count;
  }

  FilterCriteria copyWith({
    TeamTypeFilter? teamType,
    String? competitionId,
    bool clearCompetition = false,
    double? minStars,
  }) {
    return FilterCriteria(
      teamType: teamType ?? this.teamType,
      competitionId:
          clearCompetition ? null : (competitionId ?? this.competitionId),
      minStars: minStars ?? this.minStars,
    );
  }

  /// Preset factory constructors for Quick Play
  static const FilterCriteria allTeams = FilterCriteria();

  static const FilterCriteria clubsOnly = FilterCriteria(
    teamType: TeamTypeFilter.clubs,
  );

  static const FilterCriteria nationalTeamsOnly = FilterCriteria(
    teamType: TeamTypeFilter.nationalTeams,
  );

  static const FilterCriteria topClubs = FilterCriteria(
    teamType: TeamTypeFilter.clubs,
    minStars: 4.0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterCriteria &&
          runtimeType == other.runtimeType &&
          teamType == other.teamType &&
          competitionId == other.competitionId &&
          minStars == other.minStars;

  @override
  int get hashCode =>
      teamType.hashCode ^ (competitionId?.hashCode ?? 0) ^ minStars.hashCode;
}

class ActiveFilterTag {
  final String key; // 'type' | 'competition' | 'stars'
  final String label;

  const ActiveFilterTag({required this.key, required this.label});
}
