import 'package:flutter/material.dart';
import 'package:hive_notes/models/note_model.dart';
import 'package:hive_notes/services/notes_service.dart';

class NoteEditScreen extends StatefulWidget {
  final Note note;
  final bool isNew;

  const NoteEditScreen({super.key, required this.note, required this.isNew});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocus;
  late FocusNode _contentFocus;
  bool _isModified = false;
  final NotesService _notesService = NotesService();

  void _onTextChange() {
    // Check if the title or content has changed
    final titleChanged = _titleController.text != widget.note.title;
    final contentChanged = _contentController.text != widget.note.content;
    if ((titleChanged || contentChanged) && !_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _titleFocus = FocusNode();
    _contentFocus = FocusNode();

    // Set focus to title if it's a new empty note
    if (widget.isNew && widget.note.title.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocus.requestFocus();
      });
    }

    // Add listeners to the text fields
    _titleController.addListener(_onTextChange);
    _contentController.addListener(_onTextChange);
  }

  Future<bool> _onWillPop() async {
    // Check if the note has been modified
    if (!_isModified) return true;

    // Show a confirmation dialog if there are unsaved changes
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text(
                  'You have unsaved changes. Do you want to discard them?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Don't allow pop
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true), // Allow pop
                    child: const Text('Discard'),
                  ),
                ],
              ),
        ) ??
        // If the dialog is dismissed, return false
        false;
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Don't save empty note
    if (title.isEmpty && content.isEmpty) {
      // If it's a new note and both fields are empty
      // just pop without saving
      if (widget.isNew) {
        Navigator.pop(context, false);
        return;
      }

      final shouldDelete = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Delete Empty Note'),
              content: const Text('Do you want to delete this empty note?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Don't allow pop
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Allow pop
                  child: const Text('Delete'),
                ),
              ],
            ),
      );

      if (shouldDelete == true) {
        await _notesService.deleteNote(widget.note.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
        return;
      }
    }

    // Update the note with new values
    final updatedNote = Note(
      id: widget.note.id,
      title: title,
      content: content,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
    );

    if (widget.isNew) {
      await _notesService.addNote(updatedNote);
    } else {
      await _notesService.updateNote(updatedNote);
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate a successful save
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isNew ? 'New Note' : 'Edit Note'),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveNote)],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocus,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: InputBorder.none,
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
                  _contentFocus.requestFocus();
                },
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocus,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
