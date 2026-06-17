import 'package:journal/models/journal.dart';

class SyncAction {
  final String type;
  final Journal journal;

  SyncAction({
    required this.type,
    required this.journal,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'journal': journal.toJson(),
    };
  }

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      type: json['type'],
      journal: Journal.fromJson(json['journal']),
    );
  }
}