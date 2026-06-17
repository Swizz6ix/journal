import 'dart:async';

import 'package:flutter/material.dart';
import 'package:journal/events/init_journal.dart';
import 'package:journal/events/journal_edit_events.dart';
import 'package:journal/events/save_journal.dart';
import 'package:journal/events/update_date.dart';
import 'package:journal/events/update_mood.dart';
import 'package:journal/events/update_note.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/repository/journal_repository.dart';
import 'package:journal/state/journal_edit_state.dart';
import 'package:uuid/uuid.dart';

class JournalEditBloc {
  final JournalRepository repository;
  final bool isAdd;
  final ValueNotifier<JournalEditState> state;

  JournalEditBloc({
    required this.repository,
    required Journal initJournal,
    required bool add,
  }) : isAdd = add, 
      state = ValueNotifier(
    JournalEditState(journal: initJournal)
  ) {
    addEvent(InitJournal(initJournal, add));
  }

  Future<void> addEvent(JournalEditEvents event) async {
    final id = const Uuid().v4();
    print("Event received: ${event.runtimeType}");
    if (event is InitJournal) {
      final journal = event.add
        ? Journal(
            id: id, 
            uid: event.journal.uid, 
            date: DateTime.now().toIso8601String(), 
            mood: 'Very Satisfied', 
            note: '',
            lastModified: DateTime.now(),
            isSynced: false,
          )
        : event.journal;
      print('$event add on JournalEditBloc');
      state.value = state.value.copyWith(journal: journal);
    }

    if (event is UpdateDate) {
      final update = state.value.journal.copyWith(date: event.date);
      state.value = state.value.copyWith(journal: update);
    }

    if (event is UpdateMood) {
      final updated = state.value.journal.copyWith(mood: event.mood);
      state.value = state.value.copyWith(journal: updated);
    }

    if (event is UpdateNote) {
      final updated = state.value.journal.copyWith(note: event.note);
      state.value = state.value.copyWith(journal: updated);
    }

    if (event is SaveJournal) {
      print("Matched SaveJournal");
      await _save();
      print("save $event called on JournalEditBloc");
    }
  }

  Future<void> _save() async {
    final journal = state.value.journal;
    print("Saving journal: ${journal.toJson()}");

    if (isAdd) {
      print("Adding new journal");
      await repository.addJournal(journal);
      print("Added $journal");
    } else {
      print("Updating existing journal");
      await repository.updateJournal(journal);
      print("updated $journal");
    }
  }

  void dispose() {
    state.dispose();
  }
}