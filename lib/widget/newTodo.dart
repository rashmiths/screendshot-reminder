import 'package:bloc_todo/Utility.dart';
import 'package:bloc_todo/widget/check.dart';
import 'package:bloc_todo/widget/todoscreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import './todolist.dart';
import '../bloc/counter_bloc.dart';
import '../model/TODO.dart';

class NewTodo extends StatefulWidget {
  @override
  _NewTodoState createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {
  final priceNode = FocusNode();
  final _form = GlobalKey<FormState>();
  TimeOfDay _time = TimeOfDay.now();
  DateTime selectedTime = DateTime.now();
  int i = 0;
  Future<File> imageFile;
  Image imageFromPreferences;
  String imageString;
  //Future<File> imageFile;
  DateTime selectedDate = DateTime.now();
  CalendarController _controller;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  dynamic initializationSettingsAndroid;
  dynamic initializationSettingsIOS;
  dynamic initializationSettings;
  File sampleImage;
  @override
  void initState() {
    _controller = CalendarController();

    //initialization of the settings and plugin needed for local notifs
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //Used to call the _demoNotifications functions, which actually controls sending notifications
  void _showNotification(
      DateTime date, int id, String message, DateTime selectedTime) async {
    await _demoNotification(date, id, message, selectedTime);
  }

  Future<void> _demoNotification(
      DateTime date, int id, String message, DateTime selectedTime) async {
    print('######################');
    print(selectedTime.hour);
    DateTime scheduled = DateTime(date.year, date.month, date.day,
        selectedTime.hour, selectedTime.minute);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'channel_ID', 'channel name', 'channel description',
            importance: Importance.Max,
            priority: Priority.High,
            ticker: 'test ticker');
    const IOSNotificationDetails iOSChannelSpecifics = IOSNotificationDetails();
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        id, message, 'Remember to finish', scheduled, platformChannelSpecifics);
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => TodoScreen()));
  }

  Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message['data'] != null) {
      final data = message['data'];

      final title = data['title'];
      final body = data['message'];

      await _showNotification(DateTime.now(), title, title, DateTime.now());
    }
    return Future<void>.value();
  }

  // When the notification is clicked, it takes you to the app
  Future<dynamic> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload : $payload');
    }
  }

  var newProduct = TodoItem(
    DateTime.now().toString(),
    '',
    '',
    null,
    '',
    null,
  );

  Future<Null> _selectTime() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null && picked != _time) {
      _time = picked;
      setState(() {
        final now = DateTime.now();
        selectedTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }
  Future getImage() async
  {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage =tempImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload image"),
        centerTitle: true,
      ),
      body: Center(
        child: sampleImage == null ? Text("select an image") : SingleChildScrollView(
      child: Form(
        key: _form,
        child: Card(
          elevation: 5.0,
          child: Container(
            padding: EdgeInsets.only(
                // top: 10.0,
                left: 10.0,
                right: 10.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10),
            child: Column(
              children: <Widget>[
                // title field with validators
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(priceNode);
                  },
                  onSaved: (value) {
                    newProduct = TodoItem(
                        newProduct.id,
                        value,
                        newProduct.detail,
                        newProduct.date,
                        newProduct.image,
                        newProduct.time);
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
                ),
                //detail field
                TextFormField(
                    decoration: InputDecoration(labelText: 'Detail'),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    focusNode: priceNode,
                    onSaved: (value) {
                      newProduct = TodoItem(
                        newProduct.id,
                        newProduct.title,
                        value,
                        newProduct.date,
                        newProduct.image,
                        newProduct.time,
                      );
                    },
                    onFieldSubmitted: (_) {
                      final isValid = _form.currentState.validate();
                      if (!isValid) {
                        return;
                      }

                      _form.currentState.save();

                      final recentTodo = TodoItem(
                        DateTime.now().toString(),
                        newProduct.title,
                        newProduct.detail,
                        selectedDate,
                        imageString,
                        selectedTime,
                      );

                      BlocProvider.of<CounterBloc>(context)
                          .add(IncrementEvent(recentTodo));
                      _showNotification(
                        selectedDate,
                        (DateTime.now().millisecondsSinceEpoch / 1000000)
                            .round(),
                        newProduct.title,
                        selectedTime,
                      );

                      Navigator.of(context).pop();
                    }),
                //For choosing a time which may help in notification
                Row(
                  children: [
                   
                    FlatButton(
                      onPressed: () {
                        _selectTime();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'Choose Time',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                RaisedButton(
                  color: Colors.black87,
                  onPressed: () {
                    final isValid = _form.currentState.validate();
                    if (!isValid) {
                      return;
                    }

                    _form.currentState.save();

                    final recentTodo = TodoItem(
                      DateTime.now().toString(),
                      newProduct.title,
                      newProduct.detail,
                      selectedDate,
                      imageString,
                      selectedTime,
                    );
                    BlocProvider.of<CounterBloc>(context)
                        .add(IncrementEvent(recentTodo));
                    _showNotification(
                      selectedDate,
                      (DateTime.now().millisecondsSinceEpoch / 1000000).round(),
                      newProduct.title,
                      selectedTime,
                    );

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add a Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
