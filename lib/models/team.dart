class Team {
  final String id;
  final String name;
  final String type; // 'club' | 'national'
  final String country;
  final List<String> competitions;
  final double stars;
  final String logo;

  const Team({
    required this.id,
    required this.name,
    required this.type,
    required this.country,
    required this.competitions,
    required this.stars,
    required this.logo,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    // Validate and parse fields safely
    final id = (json['id'] as String?)?.trim() ?? '';
    final name = (json['name'] as String?)?.trim() ?? 'Unknown Team';
    final type = (json['type'] as String?)?.trim().toLowerCase() ?? 'club';
    final country = (json['country'] as String?)?.trim() ?? '';

    // Competitions list safely parsed
    final rawComps = json['competitions'];
    final List<String> competitions = [];
    if (rawComps is List) {
      for (final comp in rawComps) {
        if (comp != null && comp.toString().trim().isNotEmpty) {
          competitions.add(comp.toString().trim());
        }
      }
    }

    // Stars rating parsed safely (could be int, double, or null)
    double stars = 0.0;
    final rawStars = json['stars'];
    if (rawStars is num) {
      stars = rawStars.toDouble();
    } else if (rawStars is String) {
      stars = double.tryParse(rawStars) ?? 0.0;
    }
    // Clamp between 0.0 and 5.0
    if (stars < 0.0) stars = 0.0;
    if (stars > 5.0) stars = 5.0;

    final logo = (json['logo'] as String?)?.trim() ?? '';

    return Team(
      id: id,
      name: name,
      type: type,
      country: country,
      competitions: List.unmodifiable(competitions),
      stars: stars,
      logo: logo,
    );
  }

  bool get isClub => type == 'club';
  bool get isNational => type == 'national';
  bool get hasLogo => logo.isNotEmpty;

  String get assetPath {
    if (logo.isEmpty) return '';
    if (logo.startsWith('assets/')) {
      return 'data/${logo.substring(7)}';
    }
    if (logo.startsWith('data/')) {
      return logo;
    }
    return 'data/$logo';
  }

  bool get isSvg => logo.toLowerCase().endsWith('.svg');
  bool get isPng => logo.toLowerCase().endsWith('.png');

  /// Formatted star rating string e.g. "5 ★" or "4.5 ★" or "3 ★"
  String get starsFormatted {
    if (stars <= 0) return '';
    if (stars % 1 == 0) {
      return '${stars.toInt()} ★';
    }
    return '$stars ★';
  }

  /// Primary league/competition or country name formatted in uppercase
  String get primaryLeagueDisplay {
    if (competitions.isNotEmpty) {
      // Find a clean display competition
      for (final comp in competitions) {
        final formatted = _formatCompName(comp);
        if (formatted.isNotEmpty) return formatted.toUpperCase();
      }
    }
    if (country.isNotEmpty) return country.toUpperCase();
    return isNational ? 'NATIONAL' : 'CLUB';
  }

  static String _formatCompName(String raw) {
    // Turn snake_case into readable words
    if (raw.contains('_')) {
      final parts = raw.split('_');
      return parts.map((w) {
        if (w.toLowerCase() == 'ea' ||
            w.toLowerCase() == 'uefa' ||
            w.toLowerCase() == 'fifa') {
          return w.toUpperCase();
        }
        if (w.isEmpty) return '';
        return w[0].toUpperCase() + w.substring(1).toLowerCase();
      }).join(' ');
    }
    return raw;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Team(id: $id, name: $name, stars: $stars, type: $type)';
}
