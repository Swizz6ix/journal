import 'package:journal/events/journal_edit_events.dart';
import 'package:journal/models/journal.dart';

class InitJournal extends JournalEditEvents {
  final Journal journal;
  final bool add;

  InitJournal(this.journal, this.add);
}