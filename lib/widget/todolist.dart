import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../model/TODO.dart';
import '../bloc/counter_bloc.dart';

class TodoList extends StatefulWidget {
  final appbar;

  final DateTime selectedDate;

  TodoList(this.appbar, this.selectedDate);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final priceNode = FocusNode();

  @override
  void dispose() {
    priceNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<CounterBloc>(context),
        builder: (BuildContext context, state) {
          //print(state.tasklist);

          List<TodoItem> recentList = state.tasklist;
          if (recentList != null) {
            //print(recentList.toString());
            recentList = recentList.where((task) {
              //for avoiding date being called on null
              if (task.date != null) {
                return task.date.day == widget.selectedDate.day &&
                    task.date.month == widget.selectedDate.month &&
                    task.date.year == widget.selectedDate.year;
              }
              return recentList != null;
            }).toList();
            recentList.sort((a, b) => a.time.compareTo(b.time));
          }

          return Container(
            height: (MediaQuery.of(context).size.height -
                    widget.appbar.preferredSize.height -
                    MediaQuery.of(context).padding.top -
                    100) *
                0.7,
            child: recentList.isEmpty
                ? Column(
                    children: <Widget>[
                      
                      Text(
                        'No Todo\'s Added!',
                        style: TextStyle(fontFamily: 'Quicksand'),
                      ),
                      Container(
                        height: 200,
                        child: Image.asset(
                          'assets/image/waiting.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemBuilder: (ctxt, index) {
                      return Column(
                        children: <Widget>[
                          Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5.0,
                              margin: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 8,
                              ),
                              child: ListTile(
                                //deleting functionality
                                onLongPress: () {
                                  //  transactionlist[index].id=DateTime.now().toString();
                                  showDialog(
                                      context: context,
                                      child: AlertDialog(
                                        title: Text(
                                            'Are you sure u want to delete'),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              BlocProvider.of<CounterBloc>(
                                                      context)
                                                  .add(DecrementEvent(
                                                      recentList[index].id));

                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('No'),
                                          ),
                                        ],
                                      ));
                                },
                                enabled: true,
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    // IconButton(
                                    //     icon: recentList[index].isCompleted
                                    //         ? Icon(
                                    //             Icons.check_box,
                                    //           )
                                    //         : Icon(
                                    //             Icons.check_box_outline_blank,
                                    //           ),
                                    //     onPressed: () {
                                    //       final TodoItem newlist = TodoItem(
                                    //         recentList[index].id,
                                    //         recentList[index].title,
                                    //         recentList[index].detail,
                                    //         recentList[index].date,
                                    //         !(recentList[index].isCompleted),
                                    //         recentList[index].time,
                                    //       );
                                    //       BlocProvider.of<CounterBloc>(context)
                                    //           .add(IncrementEvent(newlist));
                                    //     }),
                                    CircleAvatar(
                                      backgroundColor: Colors.black87,
                                      radius: 50.0,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: FittedBox(
                                            child: Text(
                                          DateFormat.jm()
                                              .format(recentList[index].time),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  recentList[index].title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quicksand'),
                                ),
                                subtitle: Text(recentList[index].detail),
                                trailing: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                    ),
                                    onPressed: () {
                                      // editingscreen(context, widget.selectedDate,
                                      //     taskList[index].id);
                                      editscreen(
                                          priceNode,
                                          context,
                                          recentList[index].id,
                                          recentList[index].title,
                                          recentList[index].detail,
                                          widget.selectedDate,
                                          recentList[index].image,
                                          recentList[index].time);
                                    }),
                              )),
                        ],
                      );
                    },
                    itemCount: recentList.length),
          );
        });
  }
}

//EDITing functionality
Future editscreen(FocusNode priceNode, BuildContext context, id, title, detail,
    date, isCompleted, time) {
  final _form = GlobalKey<FormState>();

  var editedProduct = TodoItem(
    id,
    '',
    '',
    date,
    isCompleted,
    time,
  );

  Future<Null> _selectTime() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != time) {
      final now = DateTime.now();
      time = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    final TodoItem newProduct = TodoItem(
      id,
      editedProduct.title,
      editedProduct.detail,
      editedProduct.date,
      editedProduct.image,
      time,
    );
    BlocProvider.of<CounterBloc>(context).add(IncrementEvent(newProduct));

    Navigator.of(context).pop();
  }

  return showDialog(
      context: context,
      child: Dialog(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(width: 2.0, color: Colors.black)),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          height: 240,
          child: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  initialValue: title,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(priceNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please Enter the Title';
                    }
                    if (value.startsWith(RegExp(r'[0-9]'))) {
                      return 'Title cannot start with numbers';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    editedProduct = TodoItem(
                        id,
                        value,
                        editedProduct.detail,
                        editedProduct.date,
                        editedProduct.image,
                        editedProduct.time);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Detail'),
                  initialValue: detail,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  focusNode: priceNode,
                  onSaved: (value) {
                    editedProduct = TodoItem(
                      editedProduct.id,
                      editedProduct.title,
                      value,
                      editedProduct.date,
                      editedProduct.image,
                      editedProduct.time,
                    );
                  },
                ),
                FlatButton(
                  onPressed: () {
                    _selectTime();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Change Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Text((DateFormat.jm().format(time))),
                    ],
                  ),
                ),
                RaisedButton(
                  color: Colors.black,
                  onPressed: () {
                    _saveForm();
                  },
                  child: Text(
                    'Edit Task',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ));
}
