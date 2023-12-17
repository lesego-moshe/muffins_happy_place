import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../components/habit_tile.dart';
import '../components/monthly_summary.dart';
import '../components/my_alert_box.dart';
import '../components/my_fab.dart';
import '../data/habit_database.dart';

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({Key key}) : super(key: key);

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState() {
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }

    db.updateDatabase();

    super.initState();
  }

  void checkBoxTapped(bool value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  final _newHabitNameController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            hintText: "Enter your habit",
            onSave: saveNewHabit,
            onCancel: cancelDialogBox,
          );
        });
  }

  void saveNewHabit() {
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    _newHabitNameController.clear();
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  void openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            hintText: db.todaysHabitList[index][0],
            onSave: () => saveExistingHabit(index),
            onCancel: cancelDialogBox,
          );
        });
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    Navigator.pop(context);
    _newHabitNameController.clear();
    db.updateDatabase();
  }

  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: MyFloatingActionButton(
          onPressed: createNewHabit,
        ),
        backgroundColor: Colors.grey[300],
        body: ListView(
          children: [
            MonthlySummary(
                datasets: db.heatMapDataSet,
                startDate: _myBox.get("START_DATE")),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: db.todaysHabitList.length,
                itemBuilder: (context, index) {
                  return HabitTile(
                    habitName: db.todaysHabitList[index][0],
                    habitCompleted: db.todaysHabitList[index][1],
                    onChanged: (value) => checkBoxTapped(value, index),
                    editTapped: (context) => openHabitSettings(index),
                    deleteTapped: (context) => deleteHabit(index),
                  );
                }),
          ],
        ));
  }
}
