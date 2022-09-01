import 'package:meta/meta.dart';

class TodoModel {
  final String id;
  final String task;
  final String extraNote;
  final bool complete;
  final String dateTime;

  TodoModel(
      {required this.id,
      required this.task,
      required this.extraNote,
      required this.complete,
      required this.dateTime
      });

  factory TodoModel.fromMap(Map<String, dynamic> data, String documentId) {
    String task = data['task'];
    String extraNote = data['extraNote'];
    bool complete = data['complete'];
    String dateTime = data['dateTime'].toString();

    return TodoModel(
        id: documentId, task: task, extraNote: extraNote, complete: complete,dateTime:dateTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'extraNote': extraNote,
      'complete': complete,
      'dateTime': dateTime,
    };
  }
}
