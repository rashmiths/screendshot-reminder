import 'package:hive/hive.dart';

part 'TODO.g.dart';

@HiveType(typeId: 0)
class TodoItem {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String detail;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  String image;
  @HiveField(5)
  DateTime time;

  TodoItem(
      this.id, this.title, this.detail, this.date, this.image, this.time);
}
