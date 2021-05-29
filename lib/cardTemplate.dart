import 'package:flutter/material.dart';
import 'taskInfo.dart';

class CardTemplate extends StatefulWidget {
  final Function changeCompletion;
  final Function selected;
  final TaskData task;
  final UniqueKey key;

  CardTemplate({this.changeCompletion, this.task, this.key, this.selected});

  @override
  _CardTemplateState createState() => _CardTemplateState();
}

class _CardTemplateState extends State<CardTemplate> {
  Duration timeLeft;
  Color color;
  DateTime deadline;
  bool _isHighlighted = false;

  @override
  void initState() {
    deadline = this.widget.task.deadline;
    timeLeft = deadline.difference(DateTime.now());
    decideColor();

    super.initState();
  }

  void decideColor(){
    if (this._isHighlighted){
      this.color = Color.fromARGB(255, 57, 255, 20);
    }
    else if (this.widget.task.completed){
      this.color = Colors.blue;
    }
    else if (this.timeLeft.inDays <= 2){
      this.color =  Colors.red;
    }
    else if (this.timeLeft.inDays <= 4){
      this.color =  Colors.orange;
    }
    else{
      this.color = Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: this.widget.key,
      color: this.color,
      child: ListTile(
        title: Text(this.widget.task.name),
        subtitle: Text(("${this.deadline.day}/${this.deadline.month}/${this.deadline.year}")),
        trailing: !this.widget.task.completed?Text(this.timeLeft.inDays.toString()):null,
        onTap: (){
          if (_isHighlighted){
            _isHighlighted = false;
            this.widget.selected(this.widget.task, _isHighlighted);
            decideColor();
          }
          else{
            this.widget.changeCompletion(this.widget.task, !this.widget.task.completed);
          }
          setState(() {});
        },
        onLongPress: (){
          setState(() {
            _isHighlighted = !_isHighlighted;
            decideColor();
          });
          this.widget.selected(this.widget.task, _isHighlighted);
        },
      ),
    );
  }
}
