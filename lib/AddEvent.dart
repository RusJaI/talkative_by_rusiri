import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DbConnect.dart';
import 'model/Event.dart';

class AddEvent extends StatefulWidget {
  final int year;
  final int month;
  final int day;

  const AddEvent({
    super.key,
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  AddEventState createState() => AddEventState();
}

class AddEventState extends State<AddEvent> {
  late DateTime fromDateTime;
  late DateTime toDateTime;
  bool isSuccessfullyPushedToDB = false;

  final eventnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DbConnect dbConnect = DbConnect.instance;

  @override
  void initState() {
    super.initState();
    fromDateTime = DateTime(widget.year, widget.month, widget.day, 9, 0);
    toDateTime = DateTime(widget.year, widget.month, widget.day, 9, 15);
  }

  @override
  void dispose() {
    eventnameController.dispose();
    super.dispose();
  }

  // ── Date/time pickers ───────────────────────────────────────────────────────

  Future<void> _pickFromDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: fromDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fromDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      fromDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      // Keep toDateTime at least 15 min after fromDateTime
      if (toDateTime.isBefore(fromDateTime)) {
        toDateTime = fromDateTime.add(const Duration(minutes: 15));
      }
    });
  }

  Future<void> _pickToDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: toDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(toDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      toDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _format(DateTime dt) => DateFormat('d MMM yyyy  HH:mm').format(dt);

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _saveEvent() async {
    if (_formKey.currentState?.validate() != true) return;

    final event = Event(
      eventname: eventnameController.text.trim(),
      fromdate: fromDateTime.toString(),
      todate: toDateTime.toString(),
      repeat: 1,
    );

    final val = await dbConnect.addCalenderEvent(event);
    isSuccessfullyPushedToDB = val > 0;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSuccessfullyPushedToDB
            ? 'Event Added!'
            : 'Oops! Something went wrong.'),
        backgroundColor:
            isSuccessfullyPushedToDB ? Colors.green : Colors.redAccent,
      ),
    );

    if (isSuccessfullyPushedToDB) {
      Navigator.pop(context, true);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: eventnameController,
                autofocus: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.event_note),
                  hintText: 'Event Description',
                  labelText: 'Event Description',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter valid event details';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),

            // Start date/time
            ListTile(
              leading: const Icon(Icons.play_circle_outline, color: Colors.indigo),
              title: const Text('Start'),
              subtitle: Text(_format(fromDateTime)),
              trailing: const Icon(Icons.edit_calendar),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _pickFromDateTime,
            ),
            const SizedBox(height: 12),

            // End date/time
            ListTile(
              leading: const Icon(Icons.stop_circle_outlined, color: Colors.indigo),
              title: const Text('End'),
              subtitle: Text(_format(toDateTime)),
              trailing: const Icon(Icons.edit_calendar),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _pickToDateTime,
            ),
            const SizedBox(height: 32),

            FloatingActionButton.extended(
              onPressed: _saveEvent,
              label: const Text("Save"),
              icon: const Icon(Icons.save),
              heroTag: "btn_save_event",
            ),
          ],
        ),
      ),
    );
  }
}
