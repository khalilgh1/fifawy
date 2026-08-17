import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';

class TeamLogo extends StatelessWidget {
  final Team team;
  final double size;
  final bool showShadow;

  const TeamLogo({
    super.key,
    required this.team,
    this.size = 72,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceElevated.withValues(alpha: 0.5),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: _buildLogoImage(),
    );
  }

  Widget _buildLogoImage() {
    if (!team.hasLogo || team.assetPath.isEmpty) {
      return _buildFallbackBadge();
    }

    if (team.isSvg) {
      return SvgPicture.asset(
        team.assetPath,
        width: size * 0.8,
        height: size * 0.8,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => _buildFallbackBadge(),
      );
    }

    return Image.asset(
      team.assetPath,
      width: size * 0.8,
      height: size * 0.8,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallbackBadge(),
    );
  }

  Widget _buildFallbackBadge() {
    final initials = team.name.isNotEmpty
        ? team.name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join('')
            .toUpperCase()
        : 'FC';

    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceElevated,
              AppColors.surfaceBorder,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.accentGreen,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.28,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
