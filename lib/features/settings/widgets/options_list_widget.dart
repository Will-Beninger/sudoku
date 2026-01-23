import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/settings/settings_provider.dart';

class OptionsListWidget extends StatelessWidget {
  const OptionsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settings.isDarkMode,
              onChanged: (_) => settings.toggleTheme(),
              secondary: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Gameplay Highlights',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SwitchListTile(
              title: const Text('Highlight Row & Column'),
              subtitle: const Text(
                  'Highlights the row and column of the selected cell'),
              value: settings.highlightRowCol,
              onChanged: settings.setHighlightRowCol,
              secondary: const Icon(Icons.grid_3x3),
            ),
            SwitchListTile(
              title: const Text('Highlight Same Number'),
              subtitle: const Text(
                  'Highlights all cells containing the selected number'),
              value: settings.highlightSameNumber,
              onChanged: settings.setHighlightSameNumber,
              secondary: const Icon(Icons.format_list_numbered),
            ),
          ],
        );
      },
    );
  }
}
