import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'taskInfo.dart';
import 'dart:convert';


class DBManager{
  bool loaded = false;
  List<TaskData> data = [];
  Directory fileDir;
  File jsonFile;
  String fileName;
  Function changeFunc;
  DBManager(this.fileName, this.changeFunc){
    Future<String> rawData = this.fetchData(fileName);
    rawData.then(processData);
  }

  Future<String> fetchData(String fileName) async{
    var status = await Permission.storage.status;

    if(status.isDenied){
      await Permission.storage.request();
    }

    fileDir = await getExternalStorageDirectory();
    jsonFile = File("${fileDir.path}/$fileName");

    if (await jsonFile.exists()){
      String dat = await jsonFile.readAsString();
      return dat;
    }
    else{
      await jsonFile.create();
      jsonFile.writeAsString("[]");
      return "[]";
    }

  }

  List<TaskData> getData(){
    return this.data;
  }

  void processData(String rawData){
    List decodedData = json.decode(rawData);
    decodedData.sort((a, b)=>b['actualPriority'].compareTo(a['actualPriority']));
    for (int i = 0;i < decodedData.length;i++){
      Map task = decodedData[i];
      TaskData dataObject = TaskData(task['name'], DateTime.parse(task['deadline'])
          , task['userPriority'], task['actualPriority'], task['completed']);
      this.data.add(dataObject);
    }
    this.loaded = true;
    this.changeFunc(this.loaded);
  }

  void writeData() async{
    List stringedData = [];
    for (int i = 0;i < this.data.length;i++){
      TaskData task = this.data[i];
      Map rawTask = {'name': task.name, 'deadline': task.deadline.toString(),
        'userPriority': task.userPriority, 'actualPriority': task.actualPriority, 'completed': task.completed};
      stringedData.add(rawTask);
    }
    String rawData = json.encode(stringedData);
    await jsonFile.writeAsString(rawData);
  }

  void addTaskObject(TaskData task){
    task.deadline = task.deadline.add(Duration(hours: 23, minutes: 59, seconds: 59));
    data.add(task);
    data.sort((a, b)=>b.actualPriority.compareTo(a.actualPriority));
  }

  void addTaskNamed(String name, DateTime deadline, double userPriority, double actualPriority, bool completed){
    deadline = deadline.add(Duration(hours: 23, minutes: 59, seconds: 59));
    TaskData task = TaskData(name, deadline, userPriority, actualPriority, completed);
    data.add(task);
    data.sort((a, b)=>b.actualPriority.compareTo(a.actualPriority));
  }

  void editTask(TaskData oldTask, TaskData changedTask){
    oldTask.name = changedTask.name ?? oldTask.name;
    oldTask.deadline = changedTask.deadline ?? oldTask.deadline;
    oldTask.userPriority = changedTask.userPriority ?? oldTask.userPriority;
    oldTask.actualPriority = oldTask.userPriority;
    oldTask.completed = false;
    this.sortTasks();
    this.writeData();
  }


  void changeTaskCompletion(TaskData task, bool status){
    if (status){
      task.actualPriority = -(100 + task.userPriority);
    }
    else{
      task.actualPriority = task.userPriority;
    }
    task.completed = status;
    this.sortTasks();
    this.writeData();
  }

  void sortTasks(){
    data.sort((a, b) => b.actualPriority.compareTo(a.actualPriority));
  }

  void delete(TaskData task){
    data.remove(task);
    this.sortTasks();
    this.writeData();
  }
}