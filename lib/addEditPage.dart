import 'package:flutter/material.dart';
import 'homePage.dart';
import 'databaseManager.dart';
import 'taskInfo.dart';


class ItemPage extends StatefulWidget {
  final bool editing;
  final DBManager manager;
  final TaskData oldTask;

  ItemPage({this.editing, this.manager, this.oldTask});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  TaskData newTask;

  @override
  void initState(){
    if (this.widget.editing){
      newTask = TaskData(
          this.widget.oldTask.name,
          this.widget.oldTask.deadline,
          this.widget.oldTask.userPriority,
          this.widget.oldTask.userPriority,
          false
      );
    }
    else{
      newTask = TaskData('', DateTime.now(), 10, 10, false);
    }
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: this.newTask.deadline,
        firstDate: DateTime(2015, 8, ),
        lastDate: DateTime(2101));
    if (picked != null && picked != this.newTask.deadline)
      setState(() {
        this.newTask.deadline = picked;
      });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(manager: this.widget.manager)
              )
            );
          },
        ),
        title: this.widget.editing ? Text("Edit") : Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _key,
          child: ListView(
            children: [
              TextFormField(
                initialValue: this.newTask.name,
                decoration: InputDecoration(
                  labelText: "Task",
                  labelStyle: TextStyle(
                    fontSize: 25.0,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue
                      )
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value){
                  if (value.isEmpty){
                    return "Please enter the task name";
                  }
                  return null;
                },
                onSaved: (value){
                  this.newTask.name = value;
                },
              ),
              SizedBox(height: 10.0,),
              Text(
                "Priority",
                style: TextStyle(
                  fontSize: 20.0,
                )
              ),
              Slider(
                value: this.newTask.userPriority,
                min: 0,
                max: 100,
                divisions: 100,
                label: this.newTask.userPriority.round().toString(),
                onChanged: (value){
                  setState(() {
                    this.newTask.userPriority = value;
                  });
                }
              ),
              OutlinedButton(
                child: Text(
                  "${this.newTask.deadline.day}/${this.newTask.deadline.month}/${this.newTask.deadline.year}",
                  style: TextStyle(
                    color: Colors.black
                  ),
                ),
                onPressed: (){
                  return _selectDate(context);
                },
              ),
              ElevatedButton(
                onPressed: (){
                  if (_key.currentState.validate()){
                    _key.currentState.save();

                    if (this.widget.editing){
                      this.widget.manager.editTask(this.widget.oldTask, this.newTask);
                    }
                    else{
                      this.widget.manager.addTaskObject(this.newTask);
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(manager: this.widget.manager,)
                      )
                    );
                  }
                },
                child: this.widget.editing ? Text("Confirm") : Text("Add"),
              )
            ],
          )
        ),
      ),
    );
  }
}
