import 'package:journal/events/journal_edit_events.dart';

class UpdateMood extends JournalEditEvents {
  final String mood;
  UpdateMood(this.mood);
}