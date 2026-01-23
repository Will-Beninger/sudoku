import 'package:flutter/material.dart';

class WinDialogWidget extends StatelessWidget {
  final Duration timeTaken;
  final VoidCallback onRestart;

  const WinDialogWidget({
    super.key,
    required this.timeTaken,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
