# Hive Notes

A lightweight Flutter note-taking application built with Hive for local data storage.

<img width="559" alt="image" src="https://github.com/user-attachments/assets/4394e7ff-9812-4db7-aade-2e4d3e559c41" />
<img width="559" alt="image" src="https://github.com/user-attachments/assets/297641a6-68f5-4ef8-927a-6a5c9febabc8" />


## Features

- Create, read, update, and delete notes
- Clean Material 3 design
- Persistent local storage using Hive

## Technical Overview

This project demonstrates how to use Hive, a lightweight and fast key-value database optimized for Flutter. Here's a step-by-step breakdown of how the application is built.

### 1. Project Setup

First, we set up a Flutter project with the necessary dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.5
  uuid: ^4.1.0
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  hive_generator: ^2.0.0
  build_runner: ^2.3.3
```

### 2. Data Model Definition

We define a `Note` model with Hive annotations for type-safe persistence:

```dart
@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });
}
```

These annotations tell Hive how to serialize and deserialize our data. Each field gets a unique number that must remain consistent to ensure data integrity.

### 3. Code Generation

Run the build_runner to generate the necessary TypeAdapter for Hive:

```sh
flutter pub run build_runner build
```

This creates the `note_model.g.dart` file with the NoteAdapter class that Hive uses to store and retrieve Note objects.

### 4. Hive Initialization

In `main.dart`, we initialize Hive before the app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notesBox');
  runApp(const MyApp());
}
```

This process:

1. Ensures Flutter is initialized
2. Gets the app's document directory for persistent storage
3. Initializes Hive with this directory
4. Registers our custom Note adapter
5. Opens a Hive box called 'notesBox' that will store our Note objects

### 5. Data Service Layer

We create a service layer to abstract Hive operations:

```dart
class NotesService {
  final Box<Note> _notesBox = Hive.box<Note>('notesBox');

  List<Note> getAllNotes() { ... }
  Future<void> addNote(Note note) async { ... }
  Note? getNote(String id) { ... }
  Future<void> updateNote(Note note) async { ... }
  Future<void> deleteNote(String id) async { ... }
}
```

This service handles all CRUD operations and provides error handling.

### 6. UI Implementation

The app consists of two main screens:

#### Notes List Screen

- Displays a grid of notes using `ValueListenableBuilder` to automatically react to data changes
- Sorts notes by last updated time
- Provides a floating action button to create new notes
- Shows an empty state when no notes exist

#### Note Edit Screen

- Handles both creating new notes and editing existing ones
- Uses `WillPopScope` to prompt users about unsaved changes
- Supports deleting empty notes
- Applies a consistent color to each note based on its ID

### 7. Theming

The app uses Material 3 with a seed color to generate a consistent color scheme:

```dart
static ThemeData get theme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.light,
  ),
  // Additional theme customization...
);
```

## How it Works

### Data Flow

1. When the app starts, Hive initializes and opens the notes box
2. The `NotesListScreen` displays all notes using `ValueListenableBuilder` to watch for changes
3. When a note is created or edited:
   - A UUID is generated for new notes
   - The `NoteEditScreen` handles user input
   - On save, the `NotesService` updates the Hive box
   - The UI automatically refreshes due to the `ValueListenableBuilder`

### Hive Benefits

- **Performance**: Hive is extremely fast, outperforming other local databases like SQLite for most operations
- **Type Safety**: The generated adapters provide compile-time type checking
- **Simplicity**: No SQL knowledge required
- **Cross-Platform**: Works consistently on all Flutter platforms
- **Minimal Boilerplate**: Annotations reduce the amount of code needed

## Installation

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build` to generate the Hive adapters
4. Run `flutter run` to launch the app

## Preview

https://github.com/user-attachments/assets/e28bebf0-fba3-4520-9082-2b375b1d807d
