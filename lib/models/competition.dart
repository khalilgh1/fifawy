class Competition {
  final String id;
  final String name;
  final List<String> rawKeys;
  final bool isInternational;
  final int teamCount;

  const Competition({
    required this.id,
    required this.name,
    required this.rawKeys,
    this.isInternational = false,
    this.teamCount = 0,
  });

  Competition copyWith({
    String? id,
    String? name,
    List<String>? rawKeys,
    bool? isInternational,
    int? teamCount,
  }) {
    return Competition(
      id: id ?? this.id,
      name: name ?? this.name,
      rawKeys: rawKeys ?? this.rawKeys,
      isInternational: isInternational ?? this.isInternational,
      teamCount: teamCount ?? this.teamCount,
    );
  }

  /// Check if a team's competition raw strings match this competition
  bool matches(List<String> teamCompetitions) {
    for (final comp in teamCompetitions) {
      if (rawKeys.contains(comp)) return true;
      if (normalizeKey(comp) == id) return true;
    }
    return false;
  }

  /// Normalizes any raw competition key into a canonical ID
  static String normalizeKey(String raw) {
    final lower = raw.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    // Map known variations to canonical id
    if (lower == 'uefa_champions_league' || lower == 'champions_league') {
      return 'uefa_champions_league';
    }
    if (lower == 'uefa_europa_league' || lower == 'europa_league') {
      return 'uefa_europa_league';
    }
    if (lower == 'fifa_world_cup' || lower == 'world_cup') {
      return 'fifa_world_cup';
    }
    if (lower == 'uefa_euro_championship' || lower == 'euro_championship' || lower == 'euro') {
      return 'uefa_euro_championship';
    }
    if (lower == 'laliga_ea_sports' || lower == 'la_liga' || lower == 'laliga') {
      return 'laliga_ea_sports';
    }
    if (lower == 'premier_league' || lower == 'epl') {
      return 'premier_league';
    }
    return lower;
  }

  /// Canonical mapping to a clean display name
  static String getDisplayName(String canonicalId, [String? sampleRaw]) {
    switch (canonicalId) {
      case 'uefa_champions_league':
        return 'Champions League';
      case 'uefa_europa_league':
        return 'Europa League';
      case 'fifa_world_cup':
        return 'FIFA World Cup';
      case 'uefa_euro_championship':
        return 'UEFA Euro';
      case 'premier_league':
        return 'Premier League';
      case 'laliga_ea_sports':
        return 'La Liga';
      case 'serie_a':
        return 'Serie A';
      case 'bundesliga':
        return 'Bundesliga';
      case 'ligue':
        return 'Ligue 1';
      case 'eredivisie':
        return 'Eredivisie';
      case 'super_lig':
        return 'Süper Lig';
      case 'liga_portugal':
        return 'Liga Portugal';
      case 'jupiler_pro_league':
        return 'Jupiler Pro League';
      case 'pko_ekstraklasa':
        return 'Ekstraklasa';
      case 'premier_liga':
        return 'Premier Liga';
      case 'chance_liga':
        return 'Chance Liga';
      case 'superliga':
        return 'Superliga';
      case 'eliteserien':
        return 'Eliteserien';
      case 'allsvenskan':
        return 'Allsvenskan';
      case 'ligat_ha_al':
        return 'Ligat Ha\'al';
      case 'efbet_liga':
        return 'efbet Liga';
      case 'super_liga_srbije':
        return 'Super Liga Srbije';
      case 'super_league_1':
        return 'Super League 1';
      case 'admiral_bundesliga':
        return 'Austrian Bundesliga';
      case 'credit_suisse_super_league':
        return 'Swiss Super League';
      case 'cinch_premiership':
        return 'Scottish Premiership';
      case '3f_superliga':
        return '3F Superliga';
      case 'africa_cup_of_nations':
        return 'Africa Cup of Nations';
      case 'supersport_hnl':
        return 'SuperSport HNL';
      case 'copa_america':
        return 'Copa América';
      default:
        if (sampleRaw != null && sampleRaw.isNotEmpty && !sampleRaw.contains('_')) {
          return sampleRaw;
        }
        return canonicalId
            .split('_')
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
            .join(' ');
    }
  }

  static bool isInternationalComp(String canonicalId) {
    return canonicalId == 'fifa_world_cup' ||
        canonicalId == 'uefa_euro_championship' ||
        canonicalId == 'africa_cup_of_nations' ||
        canonicalId == 'copa_america';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Competition && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
