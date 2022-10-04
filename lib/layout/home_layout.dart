import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/shared/cubit/app_cubit.dart';
import 'package:todo_list_app/shared/cubit/states.dart';
import 'package:todo_list_app/shared/widgets/common_widgets.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertToDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
                elevation: 20,
                backgroundColor: Colors.indigo,
                centerTitle: true),
            body: cubit.screens[cubit.currentIndex],
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.indigo[700],
              child: Icon(cubit.icon),
              onPressed: () {
                if (!cubit.toggle) {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                          elevation: 35,
                          (context) => Container(
                                padding: const EdgeInsets.only(
                                    top: 0, bottom: 20, left: 20, right: 20),
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.arrow_downward, size: 15),
                                          SizedBox(width: 8),
                                          Text(
                                            'Drag down to close without saving',
                                            style: TextStyle(fontSize: 15),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      appTextFormField(
                                          controller: titleController,
                                          type: TextInputType.text,
                                          validate: (String value) {
                                            if (value.isEmpty) {
                                              return 'Title must not be Empty';
                                            }
                                          },
                                          label: "Task Title",
                                          prefix: Icons.title),
                                      const SizedBox(height: 8),
                                      appTextFormField(
                                          controller: timeController,
                                          type: TextInputType.text,
                                          onTap: () {
                                            showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now())
                                                .then((value) {
                                              timeController.text = value!
                                                  .format(context)
                                                  .toString();
                                              debugPrint(timeController.text);
                                            });
                                          },
                                          validate: (String value) {
                                            if (value.isEmpty) {
                                              return 'Time must not be Empty';
                                            }
                                          },
                                          label: "Task Time",
                                          prefix: Icons.date_range),
                                      const SizedBox(height: 8),
                                      appTextFormField(
                                          controller: dateController,
                                          type: TextInputType.datetime,
                                          onTap: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.parse(
                                                        "2022-12-12"))
                                                .then((value) {
                                              dateController.text =
                                                  DateFormat.yMMMd()
                                                      .format(value!);
                                            });
                                          },
                                          validate: (String value) {
                                            if (value.isEmpty) {
                                              return 'Date must not be Empty';
                                            }
                                          },
                                          label: "Task Time",
                                          prefix: Icons.calendar_today)
                                    ],
                                  ),
                                ),
                              ))
                      .closed
                      .then((value) {
                    cubit.changeBottomSheet(toggle: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheet(toggle: true, icon: Icons.add);
                } else {
                  if (formKey.currentState!.validate()) {
                    cubit
                        .insertDatabase(
                            title: titleController.text,
                            time: timeController.text,
                            date: dateController.text)
                        .then((value) {
                      titleController.clear();
                      timeController.clear();
                      dateController.clear();
                      cubit.changeBottomSheet(toggle: false, icon: Icons.edit);
                    });
                  }
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.indigo,
              elevation: 35,
              selectedItemColor: Colors.deepOrange,
              selectedFontSize: 16,
              iconSize: 30,
              enableFeedback: true,
              selectedIconTheme: const IconThemeData(
                color: Colors.deepOrange,
              ),
              unselectedLabelStyle:
                  const TextStyle(fontStyle: FontStyle.italic),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedFontSize: 10,
              unselectedItemColor: Colors.white,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                AppCubit.get(context).changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu, color: Colors.white),
                    label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive,
                      color: Colors.white,
                    ),
                    label: 'Archived')
              ],
            ),
          );
        },
      ),
    );
  }
}
