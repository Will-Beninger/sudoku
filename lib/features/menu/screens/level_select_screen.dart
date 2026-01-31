import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/game/screens/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadRepo();
  }

  void _loadRepo() async {
    _repo = await PuzzleRepository.create();
    if (mounted) {
      setState(() {
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

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 48.0),
                        leading: CircleAvatar(
                          backgroundColor:
                              isCompleted ? Colors.green : Colors.grey,
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(puzzle.id.contains('_')
                                  ? int.parse(puzzle.id.split('_').last)
                                      .toString()
                                  : puzzle.id),
                        ),
                        title: Text('Puzzle ${puzzle.id}'),
                        subtitle: bestTime != null
                            ? Text(
                                "Best: ${bestTime.inMinutes}:${(bestTime.inSeconds % 60).toString().padLeft(2, '0')}")
                            : null,
                        onTap: () {
                          _launchLevel(context, puzzle);
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

  void _launchLevel(BuildContext context, Puzzle puzzle) {
    // Update GameProvider with new puzzle
    context.read<GameProvider>().startPuzzle(puzzle);

    // Navigate to GameScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    ).then((_) {
      // Refresh state when coming back (to update completed status)
      setState(() {
        // Trigger rebuild to fetch updated completed status from repo
      });
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
