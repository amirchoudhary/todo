import 'package:flutter/material.dart';
import 'package:todo_app/ui/auth/register_screen.dart';
import 'package:todo_app/ui/auth/sign_in_screen.dart';
import 'package:todo_app/ui/setting/setting_screen.dart';
import 'package:todo_app/ui/splash/splash_screen.dart';
import 'package:todo_app/ui/todo/create_edit_todo_screen.dart';
import 'package:todo_app/ui/todo/todos_screen.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String setting = '/setting';
  static const String create_edit_todo = '/create_edit_todo';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => const SplashScreen(),
    login: (BuildContext context) => const SignInScreen(),
    register: (BuildContext context) => const RegisterScreen(),
    home: (BuildContext context) => TodosScreen(),
    setting: (BuildContext context) => const SettingScreen(),
    create_edit_todo: (BuildContext context) => const CreateEditTodoScreen(),
  };
}
