import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fifawy/services/team_data_service.dart';
import 'package:fifawy/services/random_match_service.dart';
import 'package:fifawy/screens/home_screen.dart';

void main() {
  testWidgets('Fifawy home screen loads and displays quick play presets', (tester) async {
    final dataService = TeamDataService();
    final matchService = RandomMatchService();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          dataService: dataService,
          matchService: matchService,
        ),
      ),
    );

    // Verify Title and buttons
    expect(find.text('FIFAWY'), findsOneWidget);
    expect(find.text('GENERATE MATCH'), findsOneWidget);
    expect(find.text('ALL TEAMS'), findsOneWidget);
    expect(find.text('CLUBS'), findsOneWidget);
    expect(find.text('NATIONAL TEAMS'), findsOneWidget);
    expect(find.text('4*+ CLUBS'), findsOneWidget);
  });
}
