import 'dart:io' as converted;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/core/data/repositories/i_puzzle_repository.dart';
import 'package:sudoku/features/menu/screens/level_select_screen.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/game/screens/game_screen.dart';
import 'package:sudoku/features/settings/settings_provider.dart';
import 'package:sudoku/features/settings/screens/options_screen.dart';

import 'package:package_info_plus/package_info_plus.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _version = '';
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    // Brief delay to ensure provider is ready if needed, though usually safe in initState callback flow
    await Future.microtask(() {});
    if (!mounted) return;

    final repo = context.read<IPuzzleRepository>();
    final game = context.read<GameProvider>();

    bool hasSave = repo.hasSavedGame();

    // If we just won the game, rely on memory state even if disk hasn't caught up
    if (game.isWon) {
      hasSave = false;
    }

    if (mounted) {
      setState(() {
        _hasSavedGame = hasSave;
      });
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${info.version}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku: Always Free'),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => IconButton(
              icon: Icon(
                settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: settings.toggleTheme,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
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
                  if (_hasSavedGame)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _continueGame(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                        ),
                        child: const Text(
                          'Continue Game',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelSelectScreen(),
                        ),
                      ).then((_) => _checkSavedGame());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Play Game',
                      style: TextStyle(fontSize: 24),
                    ),
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
                          builder: (context) => const OptionsScreen(),
                        ),
                      );
                    },
                    child: const Text('Options'),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        if (converted.Platform.isWindows ||
                            converted.Platform.isLinux ||
                            converted.Platform.isMacOS) {
                          converted.exit(0);
                        }
                      },
                      child: const Text(
                        'Exit Game',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16), // Bottom padding for scroll
                ],
              ),
            ),
          ),
          if (_version.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 16,
              child: Text(
                _version,
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _continueGame(BuildContext context) async {
    final gameProvider = context.read<GameProvider>();
    await gameProvider.loadSavedGame();

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      ).then((_) => _checkSavedGame()); // Re-check when coming back
    }
  }

  void _showStatsDialog(BuildContext context) async {
    // Use Provider to get repo
    final repo = context.read<IPuzzleRepository>();
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
