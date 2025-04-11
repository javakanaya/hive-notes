import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_notes/config/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'models/note_model.dart';
import 'screens/notes_list_screen.dart';

void main() async {
  // Ensures Flutter is initialized before using platform channels
  // This is required when performing async operations before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application documents directory path
  // This provides a persistent, app-specific storage location that:
  // 1. Is protected from other apps (sandboxed)
  // 2. Won't be cleared when the app is closed
  // 3. Follows platform conventions for data storage
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  // Initialize Hive with the app documents path
  // This tells Hive where to store its database files
  // Note: A simpler approach is just 'await Hive.initFlutter()' which
  // automatically gets the correct path for the current platform
  await Hive.initFlutter(appDocumentDirectory.path);

  // Register the custom TypeAdapter for the Note class
  // This is required so Hive knows how to serialize/deserialize Note objects
  // The adapter should be generated with 'flutter pub run build_runner build'
  Hive.registerAdapter(NoteAdapter());

  // Open the Hive box (database container) for notes
  // This creates or opens an existing database named 'notesBox'
  // All Note objects will be stored in this box
  await Hive.openBox<Note>('notesBox');

  // Start the Flutter application after all async setup is complete
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: AppTheme.theme,
      home: const NotesListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
