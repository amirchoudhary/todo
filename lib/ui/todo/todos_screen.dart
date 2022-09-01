import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/ui/todo/todos_extra_actions.dart';
import '../../models/todo_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../services/firestore_database.dart';
import '../drawer.dart';
import 'empty_content.dart';

class TodosScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TodosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Todo App'),
        actions: <Widget>[
          StreamBuilder(
              stream: firestoreDatabase.todosStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<TodoModel> todos = snapshot.data as List<TodoModel>;
                  return Visibility(
                      visible: todos.isNotEmpty ? true : false,
                      child: const TodosExtraActions());
                } else {
                  return const SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            Routes.create_edit_todo,
          );
        },
      ),
      backgroundColor: const Color(0XFFFAFAFA),
      body: WillPopScope(
          onWillPop: () async => false, child: _buildBodySection(context)),
    );
  }

  Widget _buildBodySection(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    return StreamBuilder(
        stream: firestoreDatabase.todosStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<TodoModel> todos = snapshot.data as List<TodoModel>;
            if (todos.isNotEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHelloWidget(context: context),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildDateWidget(),
                        const Divider(),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildTaskTypesWidget(context: context),
                        ),
                        const SizedBox(height: 10.0),
                        const Divider(
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: todos.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        print('dateTime: ' + todos[index].dateTime);
                        return Dismissible(
                          background: Container(
                            color: Colors.red,
                            child: Center(
                                child: Text(
                              'Delete',
                              style: TextStyle(
                                  color: Theme.of(context).canvasColor),
                            )),
                          ),
                          key: Key(todos[index].id),
                          onDismissed: (direction) {
                            firestoreDatabase.deleteTodo(todos[index]);

                            _scaffoldKey.currentState!.showSnackBar(SnackBar(
                              backgroundColor:
                                  Theme.of(context).appBarTheme.color,
                              content: Text(
                                'Deleted' + todos[index].task,
                                style: TextStyle(
                                    color: Theme.of(context).canvasColor),
                              ),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Theme.of(context).canvasColor,
                                onPressed: () {
                                  firestoreDatabase.setTodo(todos[index]);
                                },
                              ),
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: Theme.of(context).iconTheme.color!),
                              ),
                              tileColor: Colors.amberAccent.withOpacity(0.33),
                              leading: Checkbox(
                                  checkColor: Colors.black,
                                  activeColor:
                                      Theme.of(context).iconTheme.color,
                                  value: todos[index].complete,
                                  onChanged: (value) {
                                    TodoModel todo = TodoModel(
                                        id: todos[index].id,
                                        task: todos[index].task,
                                        extraNote: todos[index].extraNote,
                                        complete: value!,
                                        dateTime: todos[index].dateTime);
                                    firestoreDatabase.setTodo(todo);
                                  }),
                              title: Text(todos[index].task),
                              trailing: Text(
                                  todos[index].dateTime),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    Routes.create_edit_todo,
                                    arguments: todos[index]);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return EmptyContentWidget(
                title: 'Nothing here',
                message: 'Add a new item to get started',
                key: const Key('EmptyContentWidget'),
              );
            }
          } else if (snapshot.hasError) {
            print('error: ' + snapshot.error.toString());
            return EmptyContentWidget(
              title: 'Something went wrong',
              message: "Can't load data right now",
              key: const Key('EmptyContentWidget'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildHelloWidget({required BuildContext context}) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Hello',
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: const Color(0xFF433D82),
                fontSize: 24,
              ),
        ),
        StreamBuilder(
            stream: authProvider.user,
            builder: (context, snapshot) {
              final UserModel? user = snapshot.data as UserModel?;
              return Text(user != null ? user.email! : 'Guest',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: const Color(0xFF433D82),
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ));
            }),
      ],
    );
  }

  Widget _buildDateWidget() {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        style: const TextStyle(
          fontSize: 14.0,
          color: Color(0xFF878695),
        ),
        children: <TextSpan>[
          TextSpan(
            text: DateFormat("EEEEE", "en_US").format(DateTime.now()) + ', ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: DateFormat.yMMMMd("en_US").format(DateTime.now()),
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypesWidget({required BuildContext context}) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    return StreamBuilder(
        stream: firestoreDatabase.todosStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<TodoModel> todos = snapshot.data as List<TodoModel>;
            int count = 0;
            for (int i = 0; i < todos.length; i++) {
              if (todos[i].complete == true) {
                count++;
              }
            }
            if (todos.isNotEmpty) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildTaskStatusWidget(
                        context: context,
                        count: todos.length.toString(),
                        title: 'Created'),
                    _buildTaskStatusWidget(
                        context: context,
                        count: count.toString(),
                        title: 'Completed'),
                  ]);
            } else {
              return EmptyContentWidget(
                title: 'Nothing here',
                message: 'Add a new item to get started',
                key: const Key('EmptyContentWidget'),
              );
            }
          } else if (snapshot.hasError) {
            print('error: ' + snapshot.error.toString());
            return EmptyContentWidget(
              title: 'Something went wrong',
              message: "Can't load data right now",
              key: const Key('EmptyContentWidget'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildTaskStatusWidget(
      {required BuildContext context,
      required String count,
      required String title}) {
    return Row(
      children: <Widget>[
        Text(
          count,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: const Color(0xFF433D82),
                fontSize: 18,
              ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          '$title \nTasks',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF878695),
          ),
        )
      ],
    );
  }
}
