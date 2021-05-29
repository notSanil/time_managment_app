import 'package:flutter/material.dart';
import 'databaseManager.dart';
import 'taskInfo.dart';
import 'cardTemplate.dart';
import 'addEditPage.dart';

class HomePage extends StatefulWidget {
  final DBManager manager;

  HomePage({this.manager});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskData> data = [];

  List<Widget> body = [];

  bool cardHighlighted = false;
  TaskData highlighted;
  @override
  initState(){
    super.initState();
    data = this.widget.manager.getData();
    generateCards(this.data);
  }

  void changeTaskStatus(TaskData task, bool newStatus){
    this.widget.manager.changeTaskCompletion(task, newStatus);
    setState(() {
      generateCards(this.data);
    });
  }

  void deleteTask(TaskData task, bool status){
    setState(() {
      cardHighlighted = status;
      if (status){
        highlighted = task;
      }
      else{
        highlighted = null;
      }
    });
  }

  void generateCards(List<TaskData> data){
    this.highlighted = null;
    this.cardHighlighted = false;
    this.body = [];
    if (data.isEmpty){
      this.body.add(Text("Hooray! You have no tasks currently"));
    }
    else{
      for (int i = 0;i < data.length;i++){
        UniqueKey key = UniqueKey();
        this.body.add(CardTemplate(
            changeCompletion: changeTaskStatus,
            selected: deleteTask,
            task: data[i],
            key: key,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your tasks"),
        leading: Icon(Icons.fact_check),

        actions:[
          Visibility(
            visible: this.cardHighlighted,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemPage(
                      editing: true,
                      manager: this.widget.manager,
                      oldTask: this.highlighted,
                    ),
                  )
                );
              }
            ),
          ),
          Visibility(
            visible: this.cardHighlighted,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                this.widget.manager.delete(highlighted);
                highlighted = null;
                setState(() {
                  cardHighlighted = false;
                  generateCards(this.data);
                });
              }
            ),
          ),
        ],
      ),
      body: ListView(
        children: this.body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context)=> ItemPage(
                    manager: this.widget.manager,
                    editing: false,
                  )
              )
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
