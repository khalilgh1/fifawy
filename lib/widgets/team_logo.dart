import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';

// Pre-built shadow to avoid re-allocating on every build
const _logoShadow = [
  BoxShadow(
    color: Color(0x59000000), // ~35% black
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

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
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Use a constant-ish alpha value to avoid Color.withValues() each build
          color: const Color(0xFF1B202A).withValues(alpha: 0.5),
          boxShadow: showShadow ? _logoShadow : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.1),
          child: _buildLogoImage(),
        ),
      ),
    );
  }

  Widget _buildLogoImage() {
    if (!team.hasLogo || team.assetPath.isEmpty) {
      return _TeamInitialsBadge(name: team.name, size: size);
    }

    if (team.isSvg) {
      return SvgPicture.asset(
        team.assetPath,
        width: size * 0.8,
        height: size * 0.8,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => _TeamInitialsBadge(name: team.name, size: size),
      );
    }

    return Image.asset(
      team.assetPath,
      width: size * 0.8,
      height: size * 0.8,
      fit: BoxFit.contain,
      // cacheWidth/cacheHeight reduces memory usage for logos displayed at 78px
      cacheWidth: (size * 2).toInt(), // 2x for high-DPI
      errorBuilder: (context, error, stackTrace) =>
          _TeamInitialsBadge(name: team.name, size: size),
    );
  }
}

/// Separated into its own stateless widget so Flutter can cache the element.
class _TeamInitialsBadge extends StatelessWidget {
  final String name;
  final double size;

  const _TeamInitialsBadge({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join('')
            .toUpperCase()
        : 'FC';

    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated, AppColors.surfaceBorder],
        ),
      ),
      child: Center(
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
