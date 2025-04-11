import 'package:flutter/material.dart';
import 'package:hive_notes/config/app_theme.dart';
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
  // Store original values to check if they've become empty
  late final String _originalTitle;
  late final String _originalContent;
  late Color _noteColor;

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

    _originalTitle = widget.note.title;
    _originalContent = widget.note.content;

    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _titleFocus = FocusNode();
    _contentFocus = FocusNode();

    // Set note color based on id
    _noteColor = _getNoteColor(widget.note.id);

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

  // Get color for note
  Color _getNoteColor(String id) {
    final index = id.hashCode % AppTheme.noteColors.length;
    return AppTheme.noteColors[index];
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

      // If it's an existing note that wasn't empty before, ask about deletion
      if (_originalTitle.isNotEmpty || _originalContent.isNotEmpty) {
        final shouldDelete =
            await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Empty Note'),
                    content: const Text('Do you want to delete this empty note?'),
                    actions: [
                      TextButton(
                        onPressed:
                            () => Navigator.of(context).pop(false), // Don't allow pop
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true), // Allow pop
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            ) ??
            false;

        if (shouldDelete) {
          await _notesService.deleteNote(widget.note.id);
          if (mounted) {
            Navigator.pop(context, true);
          }
          return;
        } else {
          // If the user chooses not to delete, just pop without saving
          _titleController.text = _originalTitle;
          _contentController.text = _originalContent;
          setState(() {
            _isModified = false; // Reset the modified state
          });
        }
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
        backgroundColor: _noteColor,
        appBar: AppBar(
          backgroundColor: _noteColor,
          title: Text(widget.isNew ? 'New Note' : 'Edit Note'),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveNote)],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                focusNode: _titleFocus,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  filled: false,
                  border: InputBorder.none,
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
                  _contentFocus.requestFocus();
                },
              ),

              const Divider(height: 20),

              Expanded(
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocus,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Note Content',
                    filled: false,
                    border: InputBorder.none,
                    // Add this to align hint text to the top
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  // Add this to align text to the top
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
