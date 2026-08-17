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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Tag top right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: side.bgColor,
                borderRadius: BorderRadius.circular(12),
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
            ),
          ),

          // Main Team row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TeamLogo(
                team: team,
                size: 78,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Extra top space for badge clearance on narrow screens
                    const SizedBox(height: 4),
                    Text(
                      team.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildSecondaryInfo(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInfo(BuildContext context) {
    final List<Widget> items = [];

    // Stars
    if (team.stars > 0) {
      final starsStr = team.stars % 1 == 0
          ? '${team.stars.toInt()} ★'
          : '${team.stars} ★';

      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              starsStr,
              style: const TextStyle(
                color: AppColors.starGold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    // Dot separator
    if (items.isNotEmpty && team.primaryLeagueDisplay.isNotEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 3.5,
            height: 3.5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    // League / Competition / Country
    if (team.primaryLeagueDisplay.isNotEmpty) {
      items.add(
        Flexible(
          child: Text(
            team.primaryLeagueDisplay,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.6,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }
}
