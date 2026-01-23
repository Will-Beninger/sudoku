import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/core/data/models/puzzle.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';
import 'package:sudoku_poc/features/game/screens/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Future<List<PuzzlePack>>? _packsFuture;
  late PuzzleRepository _repo;

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
                return ListView.builder(
                  itemCount: packs.length,
                  itemBuilder: (context, index) {
                    final pack = packs[index];
                    // Group by difficulty
                    final grouped = <Difficulty, List<Puzzle>>{};
                    for (var p in pack.puzzles) {
                      grouped.putIfAbsent(p.difficulty, () => []).add(p);
                    }

                    return ExpansionTile(
                      title: Text(pack.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      initiallyExpanded: true,
                      children: grouped.entries.map((entry) {
                        final difficulty = entry.key;
                        final puzzles = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                difficulty.name.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...puzzles.map((puzzle) {
                              final isCompleted =
                                  _repo.isLevelCompleted(puzzle.id);
                              final bestTime = _repo.getBestTime(puzzle.id);

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isCompleted ? Colors.green : Colors.grey,
                                  child: isCompleted
                                      ? const Icon(Icons.check,
                                          color: Colors.white)
                                      : Text(puzzle.id
                                          .substring(puzzle.id.length - 2)),
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
                            }),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
    );
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
