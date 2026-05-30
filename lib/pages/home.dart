import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/classes/database.dart';
import 'package:journal/classes/database_file_routines.dart';
import 'package:journal/classes/journal.dart';
import 'package:journal/classes/journal_edit.dart';
import 'package:journal/pages/edit_entry.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database _database = Database(
    journal: [],
  );
  final dbRoutlines = DatabaseFileRoutines();

  Future<List<Journal>> _loadJournals() async {
    await DatabaseFileRoutines().readJournals().then((journalJson) {
      _database = dbRoutlines.databaseFromJson(journalJson);
      _database.journal.sort((comp1, comp2) 
        => DateTime.parse(comp2.date).compareTo(DateTime.parse(comp1.date)));
    });

    return _database.journal;
  }

  Future<void> _addOrEditJournal({
    required bool add, 
    required int index, 
    required Journal journal
  }) async {
    JournalEdit journalEdit = JournalEdit(action: '', journal: journal);
    
    final JournalEdit? result = await Navigator.push<JournalEdit>(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntry(
          add: add, 
          index: index, 
          journalEdit: journalEdit
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == null) return;
    journalEdit = result;

    switch (journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            _database.journal.add(journalEdit.journal);
          });
        } else {
          setState(() {
            _database.journal[index] = journalEdit.journal;
          });
        }
        await dbRoutlines.writeJournals(
          dbRoutlines.databaseToJson(_database)
        );
        break;

      case 'Cancel':
        break;
      default:
        break;
    }
  }

  // Build the ListView with Separator
  Widget _buildListViewSeparated(AsyncSnapshot<List<Journal>> snapshot) {
    return ListView.separated(
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, int index) {
        String titleDate = DateFormat.yMMMd().format(DateTime.parse(
          snapshot.data![index].date
        ));
        String subtitle = snapshot.data![index].mood + "\n" + snapshot.data![index].note;
        return Dismissible(
          key: Key(snapshot.data![index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) async {
            setState(() {
              _database.journal.removeAt(index);
            });
            await dbRoutlines.writeJournals(
              dbRoutlines.databaseToJson(_database)
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.d().format(
                          DateTime.parse(snapshot.data![index].date)
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        DateFormat.E().format(
                          DateTime.parse(snapshot.data![index].date)
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle, 
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  )
                ),
              ],
            ),
            onTap: () {
              _addOrEditJournal(
                add: false, 
                index: index, 
                journal: snapshot.data![index],
              );
            },

          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          color: Colors.grey,
        );
      } ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Journal>>(
        initialData: [],
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot<List<Journal>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return _buildListViewSeparated(snapshot);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(padding: const EdgeInsets.all(24.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        child: const Icon(Icons.add),
        onPressed: () {
          _addOrEditJournal(add: true, index: -1, journal: Journal.empty());
        }
      ),
    );
  }
}
