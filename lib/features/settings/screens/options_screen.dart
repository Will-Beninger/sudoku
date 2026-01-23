import 'package:flutter/material.dart';
import 'package:sudoku_poc/features/settings/widgets/options_list_widget.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: const SingleChildScrollView(child: OptionsListWidget()),
    );
  }
}
