// lib/pm/pages/my_job/my_job_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/my_job_provider.dart';
import '../../models/my_job_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';

enum ViewMode { list, calendar }

class MyJobPage extends StatefulWidget {
  const MyJobPage({super.key});

  @override
  State<MyJobPage> createState() => _MyJobPageState();
}

class _MyJobPageState extends State<MyJobPage> {
  ViewMode _mode = ViewMode.list;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MyJobProvider>();

    return StreamBuilder<List<MyJobModel>>(
      stream: provider.watchTodayJobs(),
      builder: (context, snapshot) {
        final jobs = snapshot.data ?? [];

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _showAddDialog(context, initialDate: _selectedDate),
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildToggle(),
                const SizedBox(height: 16),
                Expanded(
                  child: _mode == ViewMode.list
                      ? _buildList(jobs)
                      : _buildCalendar(jobs),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= TOGGLE =================

  Widget _buildToggle() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text("List View"),
          selected: _mode == ViewMode.list,
          onSelected: (_) =>
              setState(() => _mode = ViewMode.list),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("Calendar View"),
          selected: _mode == ViewMode.calendar,
          onSelected: (_) =>
              setState(() => _mode = ViewMode.calendar),
        ),
      ],
    );
  }

  // ================= LIST VIEW =================

  Widget _buildList(List<MyJobModel> jobs) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (_, index) => _jobCard(jobs[index]),
    );
  }

  // ================= CALENDAR VIEW =================

  Widget _buildCalendar(List<MyJobModel> jobs) {
    final Map<DateTime, List<MyJobModel>> events = {};

    for (final job in jobs) {
      final key =
          DateTime(job.workDate.year, job.workDate.month, job.workDate.day);
      events.putIfAbsent(key, () => []);
      events[key]!.add(job);
    }

    List<MyJobModel> _getEventsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return events[key] ?? [];
    }

    return Column(
      children: [
        TableCalendar(
          focusedDay: _selectedDate,
          firstDay: DateTime(2023),
          lastDay: DateTime(2030),
          selectedDayPredicate: (day) =>
              isSameDay(day, _selectedDate),
          onDaySelected: (selectedDay, _) {
            setState(() => _selectedDate = selectedDay);
          },

          // ❌ ปิด dot ทั้งหมด
          calendarStyle: const CalendarStyle(
            markersMaxCount: 0,
            markerSize: 0,
          ),

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) {
              final dayEvents = _getEventsForDay(date);
              final total = dayEvents.length;

              if (total == 0) {
                return Center(
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              final completed =
                  dayEvents.where((j) => j.completed).length;

              final displayNumber =
                  total > 9 ? '9+' : '$total';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayNumber,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: completed == total
                          ? Colors.green
                          : const Color(0xFF0052CC),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children:
                _getEventsForDay(_selectedDate)
                    .map(_jobCard)
                    .toList(),
          ),
        ),
      ],
    );
  }

  // ================= JOB CARD =================

  Widget _jobCard(MyJobModel job) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: job.completed,
          onChanged: (_) {
            context.read<MyJobProvider>().toggleCompleted(job);
          },
        ),
        onTap: () => _showEditDialog(context, job),
        title: Text(
          job.title,
          style: TextStyle(
            decoration:
                job.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(job.description),
              ),
            const SizedBox(height: 4),
            Text(
              "${job.workDate.day}/${job.workDate.month}/${job.workDate.year}",
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey),
            ),
            if (job.mainUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: InkWell(
                  onTap: () =>
                      launchUrl(Uri.parse(job.mainUrl)),
                  child: const Text(
                    'Open Link',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon:
              const Icon(Icons.delete, color: Colors.red),
          onPressed: () =>
              context.read<MyJobProvider>().delete(job.id),
        ),
      ),
    );
  }

  // ================= ADD =================

  void _showAddDialog(BuildContext context,
      {required DateTime initialDate}) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    DateTime selectedDate = initialDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Job'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _datePickerRow(context, selectedDate,
                    (picked) {
                  setState(() => selectedDate = picked);
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Main URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final job = MyJobModel(
                  id: '',
                  uid: '',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  workDate: selectedDate,
                  mainUrl: urlCtrl.text.trim(),
                  relatedLinks: [],
                );

                context.read<MyJobProvider>().add(job);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EDIT =================

  void _showEditDialog(BuildContext context, MyJobModel job) {
    final titleCtrl =
        TextEditingController(text: job.title);
    final descCtrl =
        TextEditingController(text: job.description);
    final urlCtrl =
        TextEditingController(text: job.mainUrl);
    DateTime selectedDate = job.workDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Job'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _datePickerRow(context, selectedDate,
                    (picked) {
                  setState(() => selectedDate = picked);
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Main URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = job.copyWith(
                  title: titleCtrl.text.trim(),
                  description:
                      descCtrl.text.trim(),
                  mainUrl: urlCtrl.text.trim(),
                  workDate: selectedDate,
                );

                context
                    .read<MyJobProvider>()
                    .update(updated);

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerRow(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onPicked,
  ) {
    return Row(
      children: [
        const Icon(Icons.calendar_today,
            size: 18),
        const SizedBox(width: 8),
        TextButton(
          child: Text(
            
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
          onPressed: () async {
            final picked =
                await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate:
                  DateTime(2020),
              lastDate:
                  DateTime(2035),
            );
            if (picked != null) {
              onPicked(picked);
            }
          },
        ),
      ],
    );
  }
}