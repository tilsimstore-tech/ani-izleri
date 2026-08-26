import 'dart:convert';
import 'package:hive/hive.dart';

part 'memory_entry.g.dart';

@HiveType(typeId: 0)
class MemoryEntry extends HiveObject {
  @HiveField(0)
  String pageId;

  @HiveField(1)
  String jsonData;

  MemoryEntry({required this.pageId, this.jsonData = '{}'});

  Map<String, dynamic> get data =>
      Map<String, dynamic>.from(jsonDecode(jsonData) as Map);

  set data(Map<String, dynamic> v) => jsonData = jsonEncode(v);

  void merge(Map<String, dynamic> patch) {
    final m = data;
    m.addAll(patch);
    data = m;
  }
}
