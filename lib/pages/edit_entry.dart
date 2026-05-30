import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/classes/journal.dart';
import 'package:journal/classes/journal_edit.dart';

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;

  const EditEntry({
    super.key,
    required this.add,
    required this.index,
    required this.journalEdit,
  });

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit _journalEdit;
  late String _title;
  late DateTime _selectedDate;
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _moodFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _journalEdit = JournalEdit(
      action: 'Cancel', 
      journal: widget.journalEdit.journal,
    );
    _title = widget.add ? 'Add' : 'Edit';
    
    if (widget.add) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(_journalEdit.journal.date);
      _moodController.text = _journalEdit.journal.mood;
      _noteController.text = _journalEdit.journal.note;
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();

    super.dispose();
  }

  // Date Picker
  Future<DateTime> _selectDate(DateTime selectedDate) async {
    final DateTime _initialDate = selectedDate;
    final DateTime? _pickedDate = await showDatePicker(
      context: context, 
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (_pickedDate == null) {
      return selectedDate;
    }
    
    return DateTime(
      _pickedDate.year,
      _pickedDate.month,
      _pickedDate.day,
      _initialDate.hour,
      _initialDate.minute,
      _initialDate.second,
      _initialDate.millisecond,
      _initialDate.microsecond
    );
  }

  void _saveEntry() {
    _journalEdit.action = 'Save';

    final String id = widget.add
      ? Random()
        .nextInt(9999999)
        .toString()
      : _journalEdit.journal.id;

    _journalEdit.journal = Journal(
      id: id, 
      date: _selectedDate.toIso8601String(), 
      mood: _moodController.text.trim(), 
      note: _noteController.text.trim(),
    );

    Navigator.pop(
      context,
      _journalEdit,
    );
  }

  void _cancelEntry() {
    _journalEdit.action = 'Cancel';

    Navigator.pop(
      context,
      _journalEdit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('$_title Entry'),
        automaticallyImplyActions: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FilledButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final DateTime _pickerDate = await _selectDate(_selectedDate);
                setState(() {
                  _selectedDate = _pickerDate;
                });
              }, 
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 22.0,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    DateFormat.yMMMEd().format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black54,
                  ),
                ],
              )
            ),
            TextField(
              controller: _moodController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              focusNode: _moodFocus,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Mood',
                icon: Icon(Icons.mood),
              ),
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_noteFocus);
              },
            ),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.newline,
              focusNode: _noteFocus,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note',
                icon: Icon(Icons.subject),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: _cancelEntry,
                  child: Text('Cancel')
                ),
                SizedBox(width: 8.0,),
                FilledButton(
                  onPressed: _saveEntry,
                  child: Text('Save')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}