import 'package:journal/events/journal_edit_events.dart';

class UpdateDate extends JournalEditEvents {
  final String date;
  UpdateDate(this.date);
}