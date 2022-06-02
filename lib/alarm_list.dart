import 'dart:io';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AlarmList {
  List<Alarm> _alarmList = List<Alarm>.empty(growable: true);
  static const String _saveFileName = 'alarms.txt';

  AlarmList();

  AlarmList.fromAlarmList(AlarmList other) : _alarmList = other._alarmList;

  AlarmList.fromJson(Map<String, dynamic> json) {
    _alarmList = List<Alarm>.empty(growable: true);
    for (var alarm in json['alarms']) {
      _alarmList.add(Alarm.fromJson(alarm));
    }
  }
  Map<String, dynamic> toJson() {
    String alarmListString = jsonEncode(_alarmList);
    return {'alarms': _alarmList};
  }

  static Future<File> getPersistenceFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = directory.path;
    final path = '$dirPath/$_saveFileName';

    var file = File(path);
    // Check if file doesn t exist (first app run),
    //   if it doesn't then create it
    if (await file.exists() != true) {
      file.create();
      file.writeAsString('{"alarms": []}');
    }

    return file;
  }

  Alarm operator [](idx) {
    return _alarmList[idx];
  }

  void add(Alarm alarm) {
    _alarmList.add(alarm);
  }

  void removeAt(int idx) {
    _alarmList.removeAt(idx);
  }

  void remove(Alarm alarm) {
    _alarmList.remove(alarm);
  }

  Future<File> saveToPersistence() async {
    final file = await getPersistenceFile();

    String stringJson = jsonEncode(this);
    print('Dumping to file');
    print(stringJson);
    file.writeAsString(stringJson);

    return file;
  }

  static Future<AlarmList> loadFromPersistence() async {
    final file = await getPersistenceFile();
    print('Loading from file');
    // Will throw json is empty
    var jsonStr = file.readAsStringSync();
    print('Decoding string: $jsonStr');

    var ret = AlarmList();
    try {
      ret = AlarmList.fromJson(jsonDecode(jsonStr));
      ret._alarmList.sort((a, b) => a.compareTo(b));
    } on FormatException catch (e) {
      print(e);
    }

    return ret;
  }

  void loadMock() async {
    var tempList = List<Alarm>.empty(growable: true);
    for (int idx = 0; idx < 3; idx++) {
      tempList.add(Alarm.fromDateTime(DateTime.now().add(Duration(days: idx))));
    }

    _alarmList = tempList;
  }

  int get length => _alarmList.length;
}

class Alarm {
  DateTime time = DateTime.now();
  // TODO: change to something more apropriate instead of milisecondsSinceEpoch
  int id = 0;

  Alarm(String timeString) {
    time = DateTime.tryParse(timeString) as DateTime;
    id = time.millisecondsSinceEpoch % 1000000000;
  }

  Alarm.fromDateTime(DateTime date) {
    time = date;
    id = time.millisecondsSinceEpoch % 1000000000;
  }

  Alarm.fromAlarm(Alarm alarm) {
    time = alarm.time;
    id = time.millisecondsSinceEpoch % 1000000000;
  }

  Alarm.fromJson(Map<String, dynamic> json)
      : time = DateTime.tryParse(json['time']) as DateTime,
        id = json['id'];
  Map<String, dynamic> toJson() => {'time': time.toString(), 'id': id};

  @override
  String toString() => DateFormat.Hm().format(time);

  int compareTo(Alarm other) => time.compareTo(other.time);
}
