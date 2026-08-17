import 'dart:math' as math;
import '../models/team.dart';
import '../models/matchup.dart';

class NotEnoughTeamsException implements Exception {
  final int count;
  const NotEnoughTeamsException(this.count);

  @override
  String toString() =>
      'NotEnoughTeamsException: Required at least 2 teams, but only found $count.';
}

class RandomMatchService {
  final math.Random _random;

  RandomMatchService([math.Random? random]) : _random = random ?? math.Random();

  /// Randomly selects two distinct teams from the eligible pool.
  /// Throws [NotEnoughTeamsException] if pool.length < 2.
  Matchup generateMatchup(
    List<Team> eligiblePool, {
    Team? previousHome,
    Team? previousAway,
  }) {
    if (eligiblePool.length < 2) {
      throw NotEnoughTeamsException(eligiblePool.length);
    }

    // Try a few times to get a different matchup than the previous one if pool is large enough
    const maxAttempts = 10;
    int attempts = 0;

    Team teamA;
    Team teamB;

    do {
      final indexA = _random.nextInt(eligiblePool.length);
      int indexB = _random.nextInt(eligiblePool.length - 1);
      if (indexB >= indexA) {
        indexB++;
      }

      teamA = eligiblePool[indexA];
      teamB = eligiblePool[indexB];
      attempts++;

      // If pool is > 2 and this is the exact same matchup as previous, try again
      if (eligiblePool.length > 2 &&
          previousHome != null &&
          previousAway != null &&
          attempts < maxAttempts) {
        final isSamePair = (teamA.id == previousHome.id && teamB.id == previousAway.id) ||
            (teamA.id == previousAway.id && teamB.id == previousHome.id);
        if (isSamePair) {
          continue;
        }
      }
      break;
    } while (attempts < maxAttempts);

    return Matchup(
      homeTeam: teamA,
      awayTeam: teamB,
      generatedAt: DateTime.now(),
    );
  }
}
