import 'package:flutter_test/flutter_test.dart';
import 'package:fifawy/models/team.dart';
import 'package:fifawy/services/random_match_service.dart';

void main() {
  group('RandomMatchService Tests', () {
    late RandomMatchService matchService;

    final teamA = const Team(
      id: 'real_madrid',
      name: 'Real Madrid',
      type: 'club',
      country: 'Spain',
      competitions: ['laliga_ea_sports', 'uefa_champions_league'],
      stars: 5.0,
      logo: 'logos/real_madrid.png',
    );

    final teamB = const Team(
      id: 'barcelona',
      name: 'FC Barcelona',
      type: 'club',
      country: 'Spain',
      competitions: ['laliga_ea_sports', 'uefa_champions_league'],
      stars: 5.0,
      logo: 'logos/fc_barcelona.png',
    );

    final teamC = const Team(
      id: 'liverpool',
      name: 'Liverpool',
      type: 'club',
      country: 'England',
      competitions: ['premier_league', 'uefa_champions_league'],
      stars: 5.0,
      logo: 'logos/liverpool_fc.png',
    );

    setUp(() {
      matchService = RandomMatchService();
    });

    test('Throws NotEnoughTeamsException if pool has fewer than 2 teams', () {
      expect(
        () => matchService.generateMatchup([]),
        throwsA(isA<NotEnoughTeamsException>()),
      );

      expect(
        () => matchService.generateMatchup([teamA]),
        throwsA(isA<NotEnoughTeamsException>()),
      );
    });

    test('Generates matchup with exactly 2 teams from pool', () {
      final matchup = matchService.generateMatchup([teamA, teamB]);
      expect(matchup.homeTeam, isNotNull);
      expect(matchup.awayTeam, isNotNull);
      expect(matchup.homeTeam.id, isNot(equals(matchup.awayTeam.id)));
      expect(
        (matchup.homeTeam.id == teamA.id && matchup.awayTeam.id == teamB.id) ||
            (matchup.homeTeam.id == teamB.id && matchup.awayTeam.id == teamA.id),
        isTrue,
      );
    });

    test('Never selects the same team for both players across 500 iterations', () {
      final pool = [teamA, teamB, teamC];
      for (int i = 0; i < 500; i++) {
        final matchup = matchService.generateMatchup(pool);
        expect(
          matchup.homeTeam.id,
          isNot(equals(matchup.awayTeam.id)),
          reason: 'Iteration $i produced identical home and away teams',
        );
      }
    });
  });
}
