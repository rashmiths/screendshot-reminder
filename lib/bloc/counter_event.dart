part of 'counter_bloc.dart';

@immutable
abstract class CounterEvent {}
class IncrementEvent extends CounterEvent {
  final TodoItem newTask;
  IncrementEvent(this.newTask);
 
}

class DecrementEvent extends CounterEvent {
  final String id;
  DecrementEvent(this.id);
  String get taskid{
    return id;
  }
  
}
