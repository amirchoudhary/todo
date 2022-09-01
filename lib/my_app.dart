import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/auth_provider.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/services/firestore_database.dart';
import 'package:todo_app/ui/auth/sign_in_screen.dart';
import 'package:todo_app/ui/home/home.dart';

import 'auth_widget_builder.dart';
import 'constants/app_themes.dart';
import 'flavor.dart';
import 'models/user_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({required Key key, required this.databaseBuilder})
      : super(key: key);

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProviderRef, __) {
        return AuthWidgetBuilder(
          databaseBuilder: databaseBuilder,
          builder: (BuildContext context,
              AsyncSnapshot<UserModel> userSnapshot) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: Provider.of<Flavor>(context).toString(),
              routes: Routes.routes,
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: themeProviderRef.isDarkModeOn
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: Consumer<AuthProvider>(
                builder: (_, authProviderRef, __) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.active) {
                    print('data: ${userSnapshot.hasData}' );
                    return userSnapshot.hasData
                        ? const HomeScreen()
                        : const SignInScreen();
                  }
                  return const Material(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            );
          },
          key: const Key('AuthWidget'),
        );
      },
    );
  }
}
