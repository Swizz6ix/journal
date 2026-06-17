import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/data/database.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        debugPrint("Creating file: ${file.path}");
        await writeJournals('{"journals": {}}');
      }

      // Read the file
      return await file.readAsString();
    } catch (e) {
      debugPrint("readJournals error: $e");
      return '{"journals": {}}';
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(json);
  }

  Future<File> getSyncQueueFile() async {
    final path = await _localPath;
    final file = File('$path/sync_queue.json');
    if (!await file.exists()) {
      debugPrint("Creating sync queue file: ${file.path}");
      return await file.writeAsString('[]');
    }
    return file;
  }

  // To read and parse from JSON data - databaseFromJson(jsonString)
  Database databaseFromJson(String json) {
    if (json.trim().isEmpty) {
      return Database(journal: {});
    }
    final Map<String, dynamic> journalMap = jsonDecode(json) as Map<String, dynamic>;
    final journalsData = journalMap['journals'];
    
    if (journalsData is List){
      final Map<String, dynamic> journalsMap = {};

      for (final journal in journalsData) {
        final journalId = Journal.fromJson(journal);
        journalsMap[journalId.id] = journal;
      }
    }

    return Database.fromJson(journalMap);
  }

  // To save and parse to JSON Data - databaseToJson(jsonString)
  String databaseToJson(Database data) {
    return json.encode(data.toJson());
  }
}