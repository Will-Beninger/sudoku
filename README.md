# Sudoku PoC

A cross-platform Sudoku application built with Flutter, "vibe coded" using **Antigravity**.

## Overview

This project is a modern, responsive Sudoku game designed to run on Windows, macOS, Linux, and Web. It demonstrates a clean architecture approach with `Provider` for state management and includes a custom-built responsive UI.

## Features

- **Cross-Platform**: Runs natively on Windows, macOS, Linux, and Web.
- **Responsive UI**:
  - Scales down gracefully on smaller screens using `FittedBox`.
  - Optimized for desktop window resizing.
- **Game Mechanics**:
  - **Standard Sudoku Board**: 9x9 grid with standard rules.
  - **Input Methods**:
    - Keyboard support (Arrows to move, Numbers to input, Backspace/Delete to clear).
    - On-screen **Number Pad** for touch/mouse input.
  - **Note Mode (Pencil)**: Toggle notes to mark multiple potential numbers in a cell.
  - **Undo System**: Robust undo history to revert moves.
  - **Hint System**: Fills a random cell (with cooldown).
  - **Win Detection**: Automatically detects win condition and shows a dialog with restart option.
- **Visuals**:
  - **Dark/Light Mode**: Full theme support togglable via the app bar.
  - **High Contrast**: Optimized text colors for readability on all backgrounds.

## Technology Stack

- **Flutter**: 3.x
- **Dart**: 3.x
- **State Management**: `provider`
- **Testing**: `flutter_test`, `fake_async` for timing tests.

## Development

Built with the assistance of Google's **Antigravity** AI agent.

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on Chrome
flutter run -d chrome
```
