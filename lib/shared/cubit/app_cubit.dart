import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_app/modules/tasks/archived_tasks_screen.dart';
import 'package:todo_list_app/modules/tasks/done_tasks_screen.dart';
import 'package:todo_list_app/modules/tasks/new_tasks_screen.dart';
import 'package:todo_list_app/shared/cubit/states.dart';


class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  IconData icon = Icons.edit;
  bool toggle = false;
  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> screens = const [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  List<String> titles = const ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppBottomNavbarState());
  }

  void changeBottomSheet({required bool toggle, required IconData icon}) {
    this.toggle = toggle;
    this.icon = icon;
    emit(AppBottomSheetState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (db, version) {
      db
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)')
          .then((value) {
        getDatabase(db);
      }).catchError((e) {
        debugPrint(e.toString());
      });
    }, onOpen: (db) {})
        .then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
        emit(AppInsertToDatabaseState());
        getDatabase(database);
      }).catchError((onError) {
        debugPrint("Error $onError");
      });

      return Future(() => null);
    });
  }

  void updateDatabase({required String status, required int id}) async {
    database.rawUpdate('UPDATE tasks SET status = ?  WHERE id = ? ',
        [status, id]).then((value) {
      getDatabase(database);
      emit(AppUpdateToDatabaseState());
    });
  }

  void deleteFromDatabase({required int id}) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?',
        [id]).then((value) {
      getDatabase(database);
      emit(AppDeleteFromDatabaseState());
    });
  }

  void getDatabase(Database db) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    db.rawQuery('SELECT * FROM tasks').then((value) {
      for (var element in value) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      }
    });
    emit(AppGetFromDatabaseState());
  }
}
