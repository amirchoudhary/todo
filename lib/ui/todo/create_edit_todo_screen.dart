import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/todo_model.dart';
import '../../services/firestore_database.dart';

class CreateEditTodoScreen extends StatefulWidget {
  const CreateEditTodoScreen({Key? key}) : super(key: key);

  @override
  _CreateEditTodoScreenState createState() => _CreateEditTodoScreenState();
}

class _CreateEditTodoScreenState extends State<CreateEditTodoScreen> {
  late TextEditingController _taskController;
  late TextEditingController _extraNoteController;
  late TextEditingController _dateController;
  String? _selectedDate;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TodoModel? _todo;
  late bool _checkboxCompleted;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TodoModel? _todoModel =
        ModalRoute.of(context)?.settings.arguments as TodoModel?;
    if (_todoModel != null) {
      _todo = _todoModel;
    }
    // print('Date: '+_todo?.dateTime ?? 'null');
    _taskController = TextEditingController(text: _todo?.task ?? "");
    _extraNoteController = TextEditingController(text: _todo?.extraNote ?? "");
    _dateController = TextEditingController(
        text: _todo?.dateTime ?? formatter.format(DateTime.now()));
    _checkboxCompleted = _todo?.complete ?? false;
    _selectedDate = _dateController.text;
  }

  DateTime currentTime = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  Future<void> _selectAssignDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Theme.of(context).iconTheme.color!, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      confirmText: 'Confirm Date',
      cancelText: 'Back',
      helpText: 'Select Task Date',
    );
    if (pickedDate != null && pickedDate != currentTime) {
      setState(() {
        currentTime = pickedDate;
        _selectedDate =
            '${getAbsoluteDate(currentTime.day)}/${getAbsoluteDate(currentTime.month)}/${currentTime.year}';
      });
    }
  }

  String getAbsoluteDate(int date) {
    return date < 10 ? '0$date' : '$date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(_todo != null ? 'Edit Todo' : 'New Todo'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus();

                  final firestoreDatabase =
                      Provider.of<FirestoreDatabase>(context, listen: false);

                  firestoreDatabase.setTodo(TodoModel(
                      id: _todo?.id ?? documentIdFromCurrentDate(),
                      task: _taskController.text,
                      extraNote: _extraNoteController.text.length > 0
                          ? _extraNoteController.text
                          : "",
                      complete: _checkboxCompleted,
                      dateTime: _selectedDate!));

                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"))
        ],
      ),
      body: _buildForm(context),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _extraNoteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _taskController,
                style: Theme.of(context).textTheme.bodyText1,
                validator: (value) =>
                    value!.isEmpty ? "Name can't be empty" : null,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).iconTheme.color!, width: 2)),
                  labelText: 'Todo Name',
                  focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).iconTheme.color!)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextFormField(
                  controller: _extraNoteController,
                  style: Theme.of(context).textTheme.bodyText1,
                  maxLines: 7,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).iconTheme.color!,
                            width: 2)),
                    labelText: 'Notes',
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(
                            color: Theme.of(context).iconTheme.color!)),
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).iconTheme.color!,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: InkWell(
                  onTap: () {
                    _selectAssignDate(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Task Date'
                                : 'Task Date : ' + _selectedDate!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).iconTheme.color!,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).iconTheme.color!,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Task Completed ?',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Checkbox(
                          value: _checkboxCompleted,
                          activeColor: Theme.of(context).iconTheme.color!,
                          onChanged: (value) {
                            setState(() {
                              _checkboxCompleted = value!;
                            });
                          })
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
