import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/team.dart';
import '../models/competition.dart';
import '../models/filter_criteria.dart';

class TeamDataService {
  List<Team> _teams = [];
  List<Competition> _competitions = [];
  bool _isLoaded = false;
  String? _loadError;

  List<Team> get teams => List.unmodifiable(_teams);
  List<Competition> get competitions => List.unmodifiable(_competitions);
  bool get isLoaded => _isLoaded;
  String? get loadError => _loadError;

  /// Loads team data from local JSON asset
  Future<void> loadTeams({String assetPath = 'data/teams_offline.json'}) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> decoded = json.decode(jsonString);

      final List<Team> loadedTeams = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final team = Team.fromJson(item);
          // Validation: id and name must exist
          if (team.id.isNotEmpty && team.name.isNotEmpty) {
            loadedTeams.add(team);
          }
        }
      }

      _teams = loadedTeams;
      _deriveCompetitions();
      _isLoaded = true;
      _loadError = null;
    } catch (e) {
      _loadError = 'Failed to load team data: $e';
      _isLoaded = false;
    }
  }

  /// Dynamically derives all canonical competitions from the loaded dataset
  void _deriveCompetitions() {
    final Map<String, Set<String>> canonicalRawMap = {};
    final Map<String, int> compTeamCounts = {};

    for (final team in _teams) {
      final Set<String> teamHandledCanonical = {};
      for (final rawComp in team.competitions) {
        final canonicalId = Competition.normalizeKey(rawComp);
        if (canonicalId.isEmpty) continue;

        canonicalRawMap.putIfAbsent(canonicalId, () => <String>{});
        canonicalRawMap[canonicalId]!.add(rawComp);

        if (!teamHandledCanonical.contains(canonicalId)) {
          teamHandledCanonical.add(canonicalId);
          compTeamCounts[canonicalId] = (compTeamCounts[canonicalId] ?? 0) + 1;
        }
      }
    }

    final List<Competition> list = [];
    for (final entry in canonicalRawMap.entries) {
      final id = entry.key;
      final rawKeys = entry.value.toList();
      final name = Competition.getDisplayName(id, rawKeys.firstOrNull);
      final isInternational = Competition.isInternationalComp(id);
      final count = compTeamCounts[id] ?? 0;

      list.add(Competition(
        id: id,
        name: name,
        rawKeys: rawKeys,
        isInternational: isInternational,
        teamCount: count,
      ));
    }

    // Sort: major European/World competitions first, then alphabetical
    list.sort((a, b) {
      // Competitions with more teams first
      if (b.teamCount != a.teamCount) {
        return b.teamCount.compareTo(a.teamCount);
      }
      return a.name.compareTo(b.name);
    });

    _competitions = list;
  }

  /// Filters the teams according to criteria
  List<Team> getEligibleTeams(FilterCriteria criteria) {
    if (!_isLoaded) return [];

    Competition? selectedComp;
    if (criteria.competitionId != null && criteria.competitionId!.isNotEmpty) {
      selectedComp = _competitions.firstWhere(
        (c) => c.id == criteria.competitionId,
        orElse: () => Competition(
          id: criteria.competitionId!,
          name: criteria.competitionId!,
          rawKeys: [criteria.competitionId!],
        ),
      );
    }

    return _teams.where((team) {
      // 1. Team Type
      if (criteria.teamType == TeamTypeFilter.clubs && !team.isClub) {
        return false;
      }
      if (criteria.teamType == TeamTypeFilter.nationalTeams && !team.isNational) {
        return false;
      }

      // 2. Competition
      if (selectedComp != null) {
        if (!selectedComp.matches(team.competitions)) {
          return false;
        }
      }

      // 3. Minimum Stars rating
      if (criteria.minStars > 0.0) {
        if (team.stars < criteria.minStars) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Find competition by canonical id
  Competition? getCompetitionById(String id) {
    for (final comp in _competitions) {
      if (comp.id == id) return comp;
    }
    return null;
  }
}
