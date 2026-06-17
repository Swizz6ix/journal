import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/models/journal.dart';

class BuildListViewSeparated extends StatelessWidget {
  final List<Journal> journals;
  final Function(String id) onDelete;
  final Function addOrEditJournal;

  const BuildListViewSeparated({
    super.key, 
    required this.journals,
    required this.addOrEditJournal,
    required this.onDelete,
  });

  // Build the ListView with Separator
  @override
  Widget build (BuildContext context) {
    return ListView.separated(
      itemCount: journals.length,
      itemBuilder: (BuildContext context, int index) {
        final journal = journals[index];
        final titleDate = DateFormat.yMMMd().format(DateTime.parse(
          journal.date
        ));
        final subtitle = "${journal.mood}\n${journal.note}";
        return Dismissible(
          key: Key(journal.uid),
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
          onDismissed: (_) async {
            onDelete(journal.uid);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Journal entry deleted')),
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
                          DateTime.parse(journal.date)
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        DateFormat.E().format(
                          DateTime.parse(journal.date)
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
              addOrEditJournal(
                add: false, 
                index: index, 
                journal: journals[index],
              );
            },

          ),
        );
      },
      separatorBuilder: (_, _) {
        return const Divider(
          color: Colors.grey,
        );
      } ,
    );
  }

}