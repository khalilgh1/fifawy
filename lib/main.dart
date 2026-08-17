import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/team_data_service.dart';
import 'services/random_match_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final dataService = TeamDataService();
  final matchService = RandomMatchService();

  runApp(FifawyApp(
    dataService: dataService,
    matchService: matchService,
  ));
}

class FifawyApp extends StatefulWidget {
  final TeamDataService dataService;
  final RandomMatchService matchService;

  const FifawyApp({
    super.key,
    required this.dataService,
    required this.matchService,
  });

  @override
  State<FifawyApp> createState() => _FifawyAppState();
}

class _FifawyAppState extends State<FifawyApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.dataService.loadTeams();
  }

  void _retryLoading() {
    setState(() {
      _initFuture = widget.dataService.loadTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fifawy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError || !widget.dataService.isLoaded) {
            return _ErrorView(
              errorMessage: widget.dataService.loadError ??
                  snapshot.error?.toString() ??
                  'Failed to load team data.',
              onRetry: _retryLoading,
            );
          }

          return HomeScreen(
            dataService: widget.dataService,
            matchService: widget.matchService,
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FIFAWY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading FC 26 teams...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.awayRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
