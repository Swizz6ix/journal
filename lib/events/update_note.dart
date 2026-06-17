import 'package:journal/events/journal_edit_events.dart';

class UpdateNote extends JournalEditEvents {
  final String note;
  UpdateNote(this.note);
}