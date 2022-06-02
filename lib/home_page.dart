import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:walarm/alarm_list.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AlarmList _alarmList = AlarmList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Walarm')),
        floatingActionButton: _createAddAlarmButton(context),
        body: FutureBuilder(
          future: AlarmList.loadFromPersistence(),
          builder: (BuildContext context, AsyncSnapshot<AlarmList> alarmList) {
            if (!alarmList.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            _alarmList = alarmList.data as AlarmList;

            return _createHomePageBody();
          },
        ));
  }

  Widget _createAddAlarmButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: _selectTime(context),
    );
  }

  VoidCallback _selectTime(BuildContext context) {
    return () async {
      var selectedTime = TimeOfDay.now();

      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.dial,
      );

      if (timeOfDay != null) {
        final now = DateTime.now();

        // If the hour is in the past for today set alarm for tmrw
        var day = now.day;
        if (now.hour > timeOfDay.hour) day += 1;

        _alarmList.add(Alarm.fromDateTime(DateTime(
            now.year, now.month, day, timeOfDay.hour, timeOfDay.minute)));

        await _alarmList.saveToPersistence();
        setState(() {});
      }
    };
  }

  Widget _createHomePageBody() {
    return ListView.builder(
      itemCount: _alarmList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          child:
              Card(child: ListTile(title: Text(_alarmList[index].toString()))),
          onDismissed: (direction) async {
            _alarmList.removeAt(index);
            await _alarmList.saveToPersistence();

            setState(() {});

            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Alarm dismissed")));
          },
        );
      },
    );
  }
}
