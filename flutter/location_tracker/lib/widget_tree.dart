import 'auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();

  static _WidgetTreeState? of(BuildContext context) =>
      context.findAncestorStateOfType<_WidgetTreeState>();
}

class _WidgetTreeState extends State<WidgetTree> {
  String _userName = '';
  set string(String value) => setState(() => _userName = value);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(userName: _userName);
          } else {
            return const LoginPage();
          }
        });
  }
}
