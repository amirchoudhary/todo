import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_database.dart';

enum TodosActions { toggleAllComplete, clearCompleted }

class TodosExtraActions extends StatelessWidget {
  const TodosExtraActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestoreDatabase = Provider.of(context);

    return PopupMenuButton<TodosActions>(
      icon: const Icon(Icons.more_vert),
      onSelected: (TodosActions result) {
        switch (result) {
          case TodosActions.toggleAllComplete:
            firestoreDatabase.setAllTodoComplete();
            break;
          case TodosActions.clearCompleted:
            firestoreDatabase.deleteAllTodoWithComplete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TodosActions>>[
        const PopupMenuItem<TodosActions>(
          value: TodosActions.toggleAllComplete,
          child: Text('Mark all complete'),
        ),
        const PopupMenuItem<TodosActions>(
          value: TodosActions.clearCompleted,
          child: Text('Clear all completed'),
        ),
      ],
    );
  }
}
