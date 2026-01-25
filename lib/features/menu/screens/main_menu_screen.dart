import 'dart:io' as converted;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku_poc/features/menu/screens/level_select_screen.dart';
import 'package:sudoku_poc/features/settings/settings_provider.dart';
import 'package:sudoku_poc/features/settings/screens/options_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku: Always Free'),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => IconButton(
              icon: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: settings.toggleTheme,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sudoku: Always Free',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LevelSelectScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('Play Game', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // TODO: Stats Screen
                  _showStatsDialog(context);
                },
                child: const Text('Statistics'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OptionsScreen()),
                  );
                },
                child: const Text('Options'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (converted.Platform.isWindows ||
                      converted.Platform.isLinux ||
                      converted.Platform.isMacOS) {
                    converted.exit(0);
                  } else {
                    SystemNavigator.pop();
                  }
                },
                child: const Text('Exit Game',
                    style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16), // Bottom padding for scroll
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context) async {
    // Quick hack to show stats for PoC
    final repo = await PuzzleRepository.create();
    final stats = repo.getStats();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Games Won: ${stats['games_won']}'),
            Text('Levels Completed: ${stats['completed_count']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
