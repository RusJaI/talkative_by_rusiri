import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AddEvent.dart';
import 'DbConnect.dart';
import 'model/Event.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  ScheduleState createState() => ScheduleState();
}

class ScheduleState extends State<Schedule> {
  final DbConnect dbConnect = DbConnect.instance;
  List<Event> eventList = [];
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await dbConnect.fetchEvents();
    if (mounted) {
      setState(() {
        eventList = events;
      });
    }
  }

  List<Event> _eventsForDay(DateTime day) {
    return eventList.where((e) {
      if (e.fromdate == null) return false;
      try {
        final eventDate = DateTime.parse(e.fromdate!);
        return eventDate.year == day.year &&
            eventDate.month == day.month &&
            eventDate.day == day.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _eventsForDay(selectedDay);

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            eventLoader: _eventsForDay,
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.indigo[400],
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (dayEvents.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: dayEvents.length,
                itemBuilder: (context, index) {
                  final event = dayEvents[index];
                  return ListTile(
                    leading: const Icon(Icons.event, color: Colors.indigo),
                    title: Text(event.eventname ?? ''),
                    subtitle: Text(event.fromdate ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        if (event.id != null) {
                          await dbConnect.deleteEvent(event.id!);
                          await _loadEvents();
                        }
                      },
                    ),
                  );
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No events for this day.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEvent(
                      year: selectedDay.year,
                      month: selectedDay.month,
                      day: selectedDay.day,
                    ),
                  ),
                );
                // Refresh if event was added
                if (result == true) {
                  await _loadEvents();
                }
              },
              label: const Text("Add Event"),
              icon: const Icon(Icons.add),
              heroTag: "btn_add_event",
            ),
          ),
        ],
      ),
    );
  }
}
