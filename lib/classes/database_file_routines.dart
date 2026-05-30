import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journal/classes/database.dart';
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
        await writeJournals('{"journals": []}');
      }

      // Read the file
      return await file.readAsString();
    } catch (e) {
      debugPrint("readJournals error: $e");
      return '{"journals": []}';
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(json);
  }

  // To read and parse from JSON data - databaseFromJson(jsonString)
  Database databaseFromJson(String str) {
    if (str.trim().isEmpty) {
      return Database(journal: []);
    }
    return Database.fromJson(
      json.decode(str) as Map<String, dynamic>,
    );
  }

  // To save and parse to JSON Data - databaseToJson(jsonString)
  String databaseToJson(Database data) {
    return json.encode(data.toJson());
  }
}