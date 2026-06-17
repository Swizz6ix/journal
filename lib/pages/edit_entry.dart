import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/classes/format_dates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/events/save_journal.dart';
import 'package:journal/events/update_date.dart';
import 'package:journal/events/update_mood.dart';
import 'package:journal/events/update_note.dart';
import 'package:journal/providers/journal_edit_bloc_provier.dart';
import 'package:journal/state/journal_edit_state.dart';

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;

  const EditEntry({
    super.key,
    required this.add,
    required this.index,
  });

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEditBloc _journalEditBloc;
  late FormatDates formatDates;
  late MoodIcons moodIcons;
  late String _title;
  TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journalEditBloc = JournalEditBlocProvier.of(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocus.dispose();

    super.dispose();
  }

  // Date Picker
  Future<String> _selectDate(String selectedDate) async {
    final DateTime initialDate = DateTime.parse(selectedDate);
    final DateTime? pickedDate = await showDatePicker(
      context: context, 
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
        initialDate.second,
        initialDate.millisecond,
        initialDate.microsecond
      ).toString();
    }
    
    return selectedDate;
  }

  Future<void> _saveEntry() async {
    await _journalEditBloc.addEvent(SaveJournal());

    print("Save entry clicked on editEntry");

    if (!mounted) return;
    
    Navigator.pop(context);
  }

  void _cancelEntry() {
    Navigator.pop(
      context,
    );
  }

  @override 
  void initState() {
    super.initState();
    formatDates = FormatDates();
    moodIcons = MoodIcons(
      title: '', 
      color: Colors.transparent,
      rotation: 0,
      icon: Icons.circle,
    );
    _noteController = TextEditingController();
    _title = widget.add ? 'Add' : 'Edit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('$_title Entry'),
        automaticallyImplyActions: false,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ValueListenableBuilder<JournalEditState>(
              valueListenable: _journalEditBloc.state, 
              builder: (context, state, _) {
                return  FilledButton(
                  onPressed: () async {
                  FocusScope.of(context).unfocus();
                  final String pickedDate = await _selectDate(state.journal.date);
                  _journalEditBloc.addEvent(UpdateDate(pickedDate));
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
                    formatDates.dateFormatShortMonthDayYear(state.journal.date),
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
            );
              }
            ),
            ValueListenableBuilder<JournalEditState>(
              valueListenable: _journalEditBloc.state, 
              builder: (context, state, _) {
                final moods = moodIcons.getMoodIconsList();
                final selectedMood = moods.firstWhere(
                  (m) => m.title == state.journal.mood,
                  orElse: () => moods.first,
                );
                return DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: selectedMood,
                    items: moodIcons.getMoodIconsList().map((MoodIcons selected) {
                      return DropdownMenuItem<MoodIcons>(
                        value: selected,
                        child: Row(
                          children: [
                            Transform(
                              transform: Matrix4.identity()..rotateZ(
                                moodIcons.getMoodRotation(selected.title)
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                moodIcons.getMoodIcon(selected.title),
                                color: moodIcons.getMoodColor(selected.title),
                              ),
                            ),
                            SizedBox(width: 15.0,),
                            Text(selected.title)
                          ],
                        )
                      );
                    }).toList(), 
                    onChanged: (MoodIcons? selected) {
                      if (selected != null) {
                        _journalEditBloc.addEvent(UpdateMood(selected.title));
                      }
                    }
                  )
                );
              }
            ),
            ValueListenableBuilder<JournalEditState>(
              valueListenable: _journalEditBloc.state, 
              builder: (context, state, _) {
          
                // Use the copyWith to make sure when you edit TextField the cursor
                // does not bounce to the first character
                _noteController.text = state.journal.note;

                return TextField(
                  controller: _noteController,
                  textInputAction: TextInputAction.newline,
                  focusNode: _noteFocus,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    icon: Icon(Icons.subject),
                  ),
                  maxLines: null,
                  onChanged: (note) => _journalEditBloc.addEvent(UpdateNote(note)),
                );
              }
            ),
            const SizedBox(height: 24.0,),
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
