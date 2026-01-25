import 'package:flutter/material.dart';

class WinDialogWidget extends StatelessWidget {
  final Duration timeTaken;
  final VoidCallback onRestart;
  final VoidCallback? onNextLevel;

  const WinDialogWidget({
    super.key,
    required this.timeTaken,
    required this.onRestart,
    this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('You Win!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Time taken: ${timeTaken.inMinutes}:${(timeTaken.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      actions: [
        if (onNextLevel != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onNextLevel!();
            },
            child: const Text('Next Level'),
          ),
        if (onNextLevel == null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close Dialog
              Navigator.of(context).pop(); // Exit GameScreen to Menu
            },
            child: const Text('Menu'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRestart();
          },
          child: const Text('Restart'),
        ),
      ],
    );
  }
}
