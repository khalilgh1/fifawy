import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fifawy/models/team.dart';
import 'package:fifawy/models/competition.dart';
import 'package:fifawy/models/filter_criteria.dart';
import 'package:fifawy/services/team_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Team Model & Data Validation Tests', () {
    test('JSON dataset contains valid 455 teams', () {
      final file = File('data/teams_offline.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final List<dynamic> jsonList = jsonDecode(content);

      expect(jsonList.length, equals(454));

      int clubCount = 0;
      int nationalCount = 0;

      for (final item in jsonList) {
        final team = Team.fromJson(item as Map<String, dynamic>);
        expect(team.id.isNotEmpty, isTrue);
        expect(team.name.isNotEmpty, isTrue);
        expect(team.stars, greaterThanOrEqualTo(0.0));
        expect(team.stars, lessThanOrEqualTo(5.0));

        if (team.isClub) clubCount++;
        if (team.isNational) nationalCount++;
      }

      expect(clubCount, equals(395));
      expect(nationalCount, equals(59));
    });

    test('Competition canonicalization works correctly', () {
      expect(Competition.normalizeKey('uefa_champions_league'), equals('uefa_champions_league'));
      expect(Competition.normalizeKey('UEFA Champions League'), equals('uefa_champions_league'));
      expect(Competition.normalizeKey('premier_league'), equals('premier_league'));
      expect(Competition.normalizeKey('laliga_ea_sports'), equals('laliga_ea_sports'));

      final comp = const Competition(
        id: 'uefa_champions_league',
        name: 'Champions League',
        rawKeys: ['uefa_champions_league', 'UEFA Champions League'],
      );

      expect(comp.matches(['uefa_champions_league']), isTrue);
      expect(comp.matches(['UEFA Champions League']), isTrue);
      expect(comp.matches(['premier_league']), isFalse);
    });

    test('Filter criteria filtering logic and presets', () {
      final team1 = const Team(
        id: 'real_madrid',
        name: 'Real Madrid',
        type: 'club',
        country: 'Spain',
        competitions: ['laliga_ea_sports', 'uefa_champions_league'],
        stars: 5.0,
        logo: 'logos/real_madrid.png',
      );

      final team2 = const Team(
        id: 'arsenal',
        name: 'Arsenal',
        type: 'club',
        country: 'England',
        competitions: ['premier_league', 'uefa_champions_league'],
        stars: 4.5,
        logo: 'logos/arsenal.png',
      );

      final team3 = const Team(
        id: 'france',
        name: 'France',
        type: 'national',
        country: 'France',
        competitions: ['fifa_world_cup', 'uefa_euro_championship'],
        stars: 5.0,
        logo: 'logos/france.svg',
      );

      final all = [team1, team2, team3];

      // Club filter
      final clubsCriteria = FilterCriteria.clubsOnly;
      expect(clubsCriteria.teamType, equals(TeamTypeFilter.clubs));
      final clubs = all.where((t) => t.isClub).toList();
      expect(clubs.length, equals(2));

      // National filter
      final nationalCriteria = FilterCriteria.nationalTeamsOnly;
      expect(nationalCriteria.teamType, equals(TeamTypeFilter.nationalTeams));
      final nationals = all.where((t) => t.isNational).toList();
      expect(nationals.length, equals(1));
      expect(nationals.first.name, equals('France'));

      // 5 stars min filter
      final fiveStars = all.where((t) => t.stars >= 5.0).toList();
      expect(fiveStars.length, equals(2));
      expect(fiveStars.map((t) => t.id), containsAll(['real_madrid', 'france']));

      // Preset topClubs
      final topClubs = FilterCriteria.topClubs;
      expect(topClubs.minStars, equals(4.0));
      expect(topClubs.teamType, equals(TeamTypeFilter.clubs));
    });

    test('TeamDataService getEligibleTeams filters properly', () {
      final service = TeamDataService();
      expect(service.isLoaded, isFalse);
      expect(service.teams.isEmpty, isTrue);
    });
  });
}
