import 'package:journal/models/journal.dart';

class Database {
  Map<String, Journal> journal;

  Database({required this.journal});

  factory Database.fromJson(Map<String, dynamic> json) {
    final raw = json["journals"];

    if (raw is List) {
      final Map<String, Journal> journalsMap = {};  

      for (final journalJson in raw) {
        final journal = Journal.fromJson(journalJson as Map<String, dynamic>);
        journalsMap[journal.id] = journal;
      }

      return Database(journal: journalsMap);
    }

    if (raw is Map<String, dynamic>) {
      final Map<String, Journal> journalsMap = {};

      raw.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final journal = Journal.fromJson(value);
          journalsMap[key] = journal;
        } else {
          print("Warning: Expected value for key '$key' to be a Map<String, dynamic>, but got ${value.runtimeType}. Skipping this entry.");
        }
      });

      return Database(journal: journalsMap);
    }

    return Database(
    journal: raw.map<String, Journal>(
      (key, value) => MapEntry(
        key, 
        Journal.fromJson(value as Map<String, dynamic>)
      )
    ));
  }

  Map<String, dynamic> toJson() => {
    "journals": journal.map((k, v) => MapEntry(k, v.toJson())),
  };
}
