import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?) onChanged;
  final Function(BuildContext) editTapped;
  final Function(BuildContext) deleteTapped;

  const HabitTile(
      {Key? key,
      required this.habitName,
      required this.habitCompleted,
      required this.onChanged,
      required this.editTapped,
      required this.deleteTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: editTapped,
              backgroundColor: Colors.grey.shade600,
              icon: CupertinoIcons.pencil,
              label: 'Edit',
              borderRadius: BorderRadius.circular(16),
            ),
            SlidableAction(
              onPressed: deleteTapped,
              backgroundColor: Colors.red,
              icon: CupertinoIcons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Checkbox(
                activeColor: Colors.pink.shade100,
                value: habitCompleted,
                onChanged: onChanged,
              ),
              Text(
                habitName,
                style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
