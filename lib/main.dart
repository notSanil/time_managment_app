import 'package:flutter/material.dart';
import 'loadingPage.dart';
import 'homePage.dart';
import 'databaseManager.dart';
import 'addEditPage.dart';

void main() {
  runApp(App());
}


class App extends StatefulWidget {
  final String jsonFileName = "tasks.json";

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _loaded = false;
  void changeState(bool loaded){
    setState(() {
      _loaded = loaded;
    });
  }

  DBManager manager;
  @override
  void initState() {
    manager = DBManager(this.widget.jsonFileName, changeState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) =>_loaded? HomePage(manager: this.manager,):LoadingPage(),
        "/addEditItem": (context) => ItemPage(),
       },
    );
  }
}
