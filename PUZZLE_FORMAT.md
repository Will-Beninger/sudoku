# Sudoku Puzzle Format

This document describes the JSON format used for Sudoku Puzzle Packs.

## File Structure

Puzzle packs are stored in `assets/puzzles/` as `.json` files. The application loads these files at startup (or on demand).

## JSON Schema

Each file represents a "Pack" of puzzles.

```json
{
  "packId": "string",          // Unique identifier for the pack (e.g., "classic_easy")
  "name": "string",            // Display name (e.g., "Classic Collection")
  "version": 1,               // Format version identifier
  "puzzles": [                 // Array of Puzzle objects
    {
      "id": "string",          // Unique ID for the puzzle
      "difficulty": "string",  // "easy", "medium", "hard", "expert"
      "initial": "string",     // 81-character string (0-9). '0' represents an empty cell.
      "solution": "string"     // 81-character string representing the completed grid.
    }
  ]
}
```

### Field Details

-   **packId**: Must be unique across all asset files.
-   **initial**: A generic row-major string of the 9x9 grid.
    -   Example: `"530070000..."`
    -   Length must be exactly 81.
    -   Only digits '0'-'9' are allowed.
-   **solution**: The target solved state. Used for validation and hints.

## Example

```json
{
  "packId": "demo_pack",
  "name": "Demo Puzzles",
  "version": 1,
  "puzzles": [
    {
      "id": "demo_001",
      "difficulty": "easy",
      "initial": "530070000600195000098000060800060003400803001700020006060000280000419005000080079",
      "solution": "534678912672195348198342567859761423426853791713924856961537284287419635345286179"
    }
  ]
}
```
