import 'dart:io' as converted;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku_poc/features/menu/screens/level_select_screen.dart';
import 'package:sudoku_poc/features/settings/theme_provider.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, theme, child) => IconButton(
              icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: theme.toggleTheme,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sudoku',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
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
              child:
                  const Text('Exit Game', style: TextStyle(color: Colors.red)),
            ),
          ],
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
