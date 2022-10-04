import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list_app/shared/cubit/app_cubit.dart';
import 'package:todo_list_app/shared/cubit/states.dart';
import 'package:todo_list_app/shared/widgets/common_widgets.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
        listener: (context,state){},
        builder: (context,state){
          var tasks = AppCubit.get(context).archivedTasks;
          return tasksBuilder(tasks: tasks);
        }
    );

  }
}
