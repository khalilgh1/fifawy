import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/team.dart';
import '../models/competition.dart';
import '../models/filter_criteria.dart';

class TeamDataService {
  List<Team> _teams = const [];
  List<Competition> _competitions = const [];
  // Index for O(1) competition lookup by canonical id
  Map<String, Competition> _competitionById = const {};
  bool _isLoaded = false;
  String? _loadError;

  // Expose the same immutable references each time (no List.unmodifiable wrapping on every call)
  List<Team> get teams => _teams;
  List<Competition> get competitions => _competitions;
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

      _teams = List.unmodifiable(loadedTeams);
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

    // Sort: competitions with more teams first, then alphabetical
    list.sort((a, b) {
      if (b.teamCount != a.teamCount) {
        return b.teamCount.compareTo(a.teamCount);
      }
      return a.name.compareTo(b.name);
    });

    _competitions = List.unmodifiable(list);

    // Build O(1) lookup index
    final index = <String, Competition>{};
    for (final comp in _competitions) {
      index[comp.id] = comp;
    }
    _competitionById = Map.unmodifiable(index);
  }

  /// Filters the teams according to criteria.
  /// Caches the last result to avoid re-filtering on repeated identical calls.
  FilterCriteria? _lastCriteria;
  List<Team> _lastResult = const [];

  List<Team> getEligibleTeams(FilterCriteria criteria) {
    if (!_isLoaded) return const [];

    // Cache hit — same criteria, return previous result
    if (_lastCriteria == criteria) return _lastResult;

    Competition? selectedComp;
    if (criteria.competitionId != null && criteria.competitionId!.isNotEmpty) {
      selectedComp = _competitionById[criteria.competitionId] ??
          Competition(
            id: criteria.competitionId!,
            name: criteria.competitionId!,
            rawKeys: [criteria.competitionId!],
          );
    }

    final result = _teams.where((team) {
      // 1. Team Type
      if (criteria.teamType == TeamTypeFilter.clubs && !team.isClub) {
        return false;
      }
      if (criteria.teamType == TeamTypeFilter.nationalTeams && !team.isNational) {
        return false;
      }

      // 2. Competition
      if (selectedComp != null && !selectedComp.matches(team.competitions)) {
        return false;
      }

      // 3. Minimum Stars rating
      if (criteria.minStars > 0.0 && team.stars < criteria.minStars) {
        return false;
      }

      return true;
    }).toList(growable: false);

    _lastCriteria = criteria;
    _lastResult = result;
    return result;
  }

  /// O(1) competition lookup via pre-built index
  Competition? getCompetitionById(String id) => _competitionById[id];
}
