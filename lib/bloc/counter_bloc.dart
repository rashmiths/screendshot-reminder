import 'dart:async';
import 'package:bloc/bloc.dart';
import '../model/TODO.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  @override
  CounterState get initialState =>
      CounterInitial(Hive.box('todo').values.toList().cast<TodoItem>());

  @override
  Stream<CounterState> mapEventToState(
    CounterEvent event,
  ) async* {
    if (event is IncrementEvent) {
      final transactionbox = Hive.box('todo');
      await transactionbox.put(event.newTask.id, event.newTask);

      List<TodoItem> recentList =
          Hive.box('todo').values.toList().cast<TodoItem>();
      //print(recentList.length);

      yield CounterInitial(recentList);
    } else if (event is DecrementEvent) {
      final transactionbox = Hive.box('todo');
      await transactionbox.delete(event.id);
      List<TodoItem> recentList =
          Hive.box('todo').values.toList().cast<TodoItem>();
      //print(recentList.length);

      yield CounterInitial(recentList);
    }
  }
}
