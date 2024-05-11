import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:muffins_happy_place/components/my_button.dart';
import 'package:muffins_happy_place/pages/period_tracking_page.dart';

import '../models/event.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final _calendarControllerToday = AdvancedCalendarController.today();
  final events = <DateTime>[];
  late Event selectedEvent;
  String selectedDayEventsMessage = 'Tap a date to see events';

  void addEventToFirestore(Event event) {
    FirebaseFirestore.instance.collection('Events').add(event.toJson());
  }

  Future<List<Event>> getEventsFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Events').get();
    return querySnapshot.docs
        .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  String getDaySuffix(int day) {
    if (!(day >= 1 && day <= 31)) {
      throw ArgumentError('Invalid day of month');
    }

    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.pink.shade100),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Calendar",
          style: TextStyle(color: Colors.pink.shade100),
        ),
      ),
      body: Builder(builder: (context) {
        final theme = Theme.of(context);

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Theme(
              data: theme.copyWith(
                textTheme: theme.textTheme.copyWith(
                  titleMedium: theme.textTheme.titleMedium!.copyWith(
                    fontSize: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  bodyLarge: theme.textTheme.bodyLarge!.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  bodyMedium: theme.textTheme.bodyMedium!.copyWith(
                    fontSize: 20,
                    color: Colors.pink.shade100,
                  ),
                ),
                primaryColor: Colors.pink.shade100,
                highlightColor: Colors.grey.shade300,
                disabledColor: Colors.grey.shade200,
                secondaryHeaderColor: Colors.pink.shade100,
              ),
              child: GestureDetector(
                onDoubleTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String? eventName;
                      return AlertDialog(
                        title: const Text('Add Event'),
                        content: TextField(
                          onChanged: (value) {
                            eventName = value;
                          },
                          decoration: const InputDecoration(
                              hintText: "Enter event name"),
                        ),
                        actions: <Widget>[
                          TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              setState(() {
                                Event event = Event(
                                    date: _calendarControllerToday.value,
                                    name: eventName);

                                events.add(event.date!);

                                addEventToFirestore(event);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: FutureBuilder<List<Event>>(
                  future: getEventsFromFirestore(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Event>> snapshot) {
                    if (snapshot.hasData) {
                      List<Event>? sortedEvents =
                          List.from(snapshot.data as Iterable)
                            ..sort((a, b) => a.date!.compareTo(b.date!));

                      Event nextEvent = sortedEvents.firstWhere(
                        (event) => event.date!.isAfter(DateTime.now()),
                      );

                      return Column(
                        children: [
                          AdvancedCalendar(
                            todayStyle:
                                const TextStyle(color: Colors.pinkAccent),
                            headerStyle:
                                const TextStyle(color: Colors.pinkAccent),
                            innerDot: true,
                            controller: _calendarControllerToday,
                            events: snapshot.data!
                                .map((event) => event.date!)
                                .toList(),
                            startWeekDay: 1,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          nextEvent != null
                              ? Center(
                                  child: Text(
                                    'Upcoming event: ${nextEvent.name} on the ${nextEvent.date!.day}${getDaySuffix(nextEvent.date!.day)} of ${DateFormat('MMMM').format(nextEvent.date!)} ${nextEvent.date!.year}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pinkAccent),
                                  ),
                                )
                              : const Text(
                                  'No upcoming event',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent),
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyButton(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PeriodTrackerScreen()));
                              },
                              text: "Track period")
                          // Display the selected day's events message
                          // Text(
                          //   selectedDayEventsMessage,
                          //   style: TextStyle(
                          //     fontSize: 15,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.pinkAccent,
                          //   ),
                          // ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Center(
                        child: Lottie.asset('lib/images/loading.json'),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
