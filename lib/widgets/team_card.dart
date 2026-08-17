import 'package:flutter/material.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import 'team_logo.dart';

enum MatchupSide {
  home('HOME', AppColors.homeGreen, AppColors.homeGreenBg),
  away('AWAY', AppColors.awayRed, AppColors.awayRedBg);

  final String label;
  final Color textColor;
  final Color bgColor;
  const MatchupSide(this.label, this.textColor, this.bgColor);
}

// Pre-built static decoration constants to avoid recreating objects on every build
const _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(24)),
  border: Border.fromBorderSide(
    BorderSide(color: AppColors.surfaceBorder, width: 1.2),
  ),
);

const _dotDecoration = BoxDecoration(
  shape: BoxShape.circle,
  color: AppColors.textMuted,
);

const _starsStyle = TextStyle(
  color: AppColors.starGold,
  fontWeight: FontWeight.w700,
  fontSize: 13,
  letterSpacing: 0.5,
);

const _leagueStyle = TextStyle(
  color: AppColors.textSecondary,
  fontWeight: FontWeight.w600,
  fontSize: 12,
  letterSpacing: 0.6,
);

const _teamNameStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.2,
  height: 1.15,
  color: AppColors.textPrimary,
);

class TeamCard extends StatelessWidget {
  final Team team;
  final MatchupSide side;

  const TeamCard({
    super.key,
    required this.team,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // HOME / AWAY tag — top right
            Positioned(
              top: 0,
              right: 0,
              child: _SideBadge(side: side),
            ),

            // Main Team row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TeamLogo(team: team, size: 78),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        team.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _teamNameStyle,
                      ),
                      const SizedBox(height: 8),
                      _TeamSecondaryInfo(team: team),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Separated into its own widget so Flutter can skip rebuilding it when unchanged.
class _SideBadge extends StatelessWidget {
  final MatchupSide side;
  const _SideBadge({required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: side.bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: side.textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        side.label,
        style: TextStyle(
          color: side.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Extracts secondary info into its own stateless widget for cheaper rebuilds.
class _TeamSecondaryInfo extends StatelessWidget {
  final Team team;
  const _TeamSecondaryInfo({required this.team});

  @override
  Widget build(BuildContext context) {
    final hasStars = team.stars > 0;
    final league = team.primaryLeagueDisplay;
    final hasLeague = league.isNotEmpty;

    if (!hasStars && !hasLeague) return const SizedBox.shrink();

    final starsStr = hasStars
        ? (team.stars % 1 == 0
            ? '${team.stars.toInt()} ★'
            : '${team.stars} ★')
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (starsStr != null) Text(starsStr, style: _starsStyle),
        if (starsStr != null && hasLeague)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              width: 3.5,
              height: 3.5,
              child: DecoratedBox(decoration: _dotDecoration),
            ),
          ),
        if (hasLeague)
          Flexible(
            child: Text(
              league,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _leagueStyle,
            ),
          ),
      ],
    );
  }
}
