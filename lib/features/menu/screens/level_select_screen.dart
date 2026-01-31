import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/game/screens/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final PuzzleRepository? repository;

  const LevelSelectScreen({super.key, this.repository});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Future<List<PuzzlePack>>? _packsFuture;
  late PuzzleRepository _repo;

  // State for accordion behavior
  // We assume puzzle packs have unique IDs, or just use names.
  String? _expandedPackName; // Which pack is open?
  Difficulty? _expandedDifficulty; // Which difficulty is open?

  String? _savedPuzzleId; // ID of the currently saved puzzle

  @override
  void initState() {
    super.initState();
    _loadRepo();
  }

  void _loadRepo() async {
    // Use injected repository from widget or Provider
    _repo = widget.repository ?? context.read<PuzzleRepository>();

    // Load saved puzzle ID
    final savedId = await _repo.getSavedPuzzleId();

    if (mounted) {
      setState(() {
        _savedPuzzleId = savedId;
        _packsFuture = _repo.loadPacks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: _packsFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<PuzzlePack>>(
              future: _packsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No levels found.'));
                }

                final packs = snapshot.data!;
                // Flatten the logic into a list of "DisplayItems"
                final displayItems = _buildDisplayItems(packs);

                return ListView.builder(
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    final item = displayItems[index];

                    if (item is _PackHeaderItem) {
                      return ListTile(
                        title: Text(item.pack.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Icon(_expandedPackName == item.pack.name
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onTap: () {
                          setState(() {
                            if (_expandedPackName == item.pack.name) {
                              _expandedPackName = null;
                            } else {
                              _expandedPackName = item.pack.name;
                              // Optionally reset difficulty when switching packs
                              _expandedDifficulty = null;
                            }
                          });
                        },
                      );
                    } else if (item is _DifficultyHeaderItem) {
                      final isExpanded = _expandedDifficulty == item.difficulty;
                      return ListTile(
                        title: Text(
                          item.difficulty.name.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 32.0),
                        onTap: () {
                          setState(() {
                            if (_expandedDifficulty == item.difficulty) {
                              _expandedDifficulty = null;
                            } else {
                              _expandedDifficulty = item.difficulty;
                            }
                          });
                        },
                      );
                    } else if (item is _PuzzleItem) {
                      final puzzle = item.puzzle;
                      final isCompleted = _repo.isLevelCompleted(puzzle.id);
                      final bestTime = _repo.getBestTime(puzzle.id);
                      final isSaved = _savedPuzzleId == puzzle.id;

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 48.0),
                        leading: CircleAvatar(
                          backgroundColor: isCompleted
                              ? Colors.green
                              : (isSaved ? Colors.orange : Colors.grey),
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white)
                              : isSaved
                                  ? const Icon(Icons.play_arrow,
                                      color: Colors.white)
                                  : Text(puzzle.id.contains('_')
                                      ? int.parse(puzzle.id.split('_').last)
                                          .toString()
                                      : puzzle.id),
                        ),
                        title: Row(
                          children: [
                            Text('Puzzle ${puzzle.id}'),
                            if (isSaved)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.orange)),
                                  child: const Text('In Progress',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                          ],
                        ),
                        subtitle: bestTime != null
                            ? Text(
                                "Best: ${bestTime.inMinutes}:${(bestTime.inSeconds % 60).toString().padLeft(2, '0')}")
                            : null,
                        onTap: () {
                          _launchLevel(context, puzzle, isSaved);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
    );
  }

  List<_ListItem> _buildDisplayItems(List<PuzzlePack> packs) {
    final items = <_ListItem>[];

    for (var pack in packs) {
      items.add(_PackHeaderItem(pack));

      if (_expandedPackName == pack.name) {
        // Pack is expanded, show difficulties
        final grouped = <Difficulty, List<Puzzle>>{};
        for (var p in pack.puzzles) {
          grouped.putIfAbsent(p.difficulty, () => []).add(p);
        }

        // Sort difficulties if needed logic (Easy, Medium, Hard, Expert)
        // Usually enum index is enough if defined in order
        final sortedDifficulties = grouped.keys.toList()
          ..sort((a, b) => a.index.compareTo(b.index));

        for (var difficulty in sortedDifficulties) {
          items.add(_DifficultyHeaderItem(difficulty));

          if (_expandedDifficulty == difficulty) {
            // Difficulty is expanded, show puzzles
            final puzzles = grouped[difficulty]!;
            for (var puzzle in puzzles) {
              items.add(_PuzzleItem(puzzle));
            }
          }
        }
      }
    }

    return items;
  }

  void _launchLevel(
      BuildContext context, Puzzle puzzle, bool isCurrentSave) async {
    if (isCurrentSave) {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resume Game?'),
          content: const Text('You have an in-progress game for this level.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'restart'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Restart Level'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'resume'),
              child: const Text('Resume'),
            ),
          ],
        ),
      );

      if (choice == 'cancel' || choice == null) return;

      if (!context.mounted) return;

      if (choice == 'resume') {
        // Load saved
        await context.read<GameProvider>().loadSavedGame();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameScreen()),
          ).then((_) => _loadRepo()); // Refresh status on return
        }
        return;
      }
      // If restart, fall through to startPuzzle logic (overwrite effectively)
    } else if (_repo.hasSavedGame()) {
      // Trying to play different level but save exists
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start New Game?'),
          content: const Text(
              'You have a saved game in progress on another level. Starting this new game will delete your current progress.\n\nAre you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Start New Game'),
            ),
          ],
        ),
      );

      if (shouldProceed != true) return;
    }

    if (!context.mounted) return;

    // Start New Game (or Restart)
    context.read<GameProvider>().startPuzzle(puzzle);

    // Navigate to GameScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    ).then((_) {
      _loadRepo(); // Refresh status on return
    });
  }
}

// Helper classes for flattened list
abstract class _ListItem {}

class _PackHeaderItem extends _ListItem {
  final PuzzlePack pack;
  _PackHeaderItem(this.pack);
}

class _DifficultyHeaderItem extends _ListItem {
  final Difficulty difficulty;
  _DifficultyHeaderItem(this.difficulty);
}

class _PuzzleItem extends _ListItem {
  final Puzzle puzzle;
  _PuzzleItem(this.puzzle);
}
