// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:walarm/home_page.dart';

const double stdPadding = 5;

void main() async {
  runApp(App());
  await AndroidAlarmManager.initialize();
}

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
