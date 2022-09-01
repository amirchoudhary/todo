import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: StreamBuilder(
                stream: authProvider.user,
                builder: (context, snapshot) {
                  final UserModel? user = snapshot.data as UserModel?;
                  return UserAccountsDrawerHeader(
                    decoration:  BoxDecoration(color: Theme.of(context).iconTheme.color),
                    accountName: Text(
                      user!.email!.substring(0, user.email!.lastIndexOf("@")),
                      style: const TextStyle(fontSize: 18),
                    ),
                    accountEmail: Text(user != null ? user.email! : 'Guest'),
                    currentAccountPictureSize: const Size.square(50),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.black87,
                      child: Text(
                        user.email!.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 30.0,
                            color: Colors.white),
                      ), //Text
                    ), //circleAvatar
                  );
                }),
            decoration: BoxDecoration(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.setting);
            },
          ),
        ],
      ),
    );
  }
}
