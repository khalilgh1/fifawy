import 'team.dart';

class Matchup {
  final Team homeTeam;
  final Team awayTeam;
  final DateTime generatedAt;

  Matchup({
    required this.homeTeam,
    required this.awayTeam,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Matchup &&
          runtimeType == other.runtimeType &&
          homeTeam.id == other.homeTeam.id &&
          awayTeam.id == other.awayTeam.id;

  @override
  int get hashCode => homeTeam.id.hashCode ^ awayTeam.id.hashCode;

  @override
  String toString() => 'Matchup(${homeTeam.name} vs ${awayTeam.name})';
}
