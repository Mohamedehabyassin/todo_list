import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/layout/home_layout.dart';
import 'package:todo_list_app/shared/bloc_observable.dart';


void main() {
  Bloc.observer = MyBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TODO List",
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}
