part of 'counter_bloc.dart';

@immutable
abstract class CounterState {
  
}

class CounterInitial extends CounterState {
  final List<TodoItem> tasklist;

  CounterInitial(this.tasklist);
  
  
}
