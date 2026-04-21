import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../provider/schedule_provider.dart';
import '../services/notification_service.dart';

void showAddScheduleSheet(BuildContext context, {ClassSchedule? schedule}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddScheduleSheet(schedule: schedule),
  );
}

class AddScheduleSheet extends StatefulWidget {
  final ClassSchedule? schedule;
  const AddScheduleSheet({super.key, this.schedule});

  @override
  State<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<AddScheduleSheet> {
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  final _instructorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late int _dayOfWeek;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _colorHex;

  final List<int> _colors = [
    0xFF7C3AED, // Purple
    0xFF06B6D4, // Cyan
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEC4899, // Pink
    0xFFEF4444, // Red
    0xFF3B82F6, // Blue
  ];

  static const _days = [
    (1, 'Monday'),
    (2, 'Tuesday'),
    (3, 'Wednesday'),
    (4, 'Thursday'),
    (5, 'Friday'),
    (6, 'Saturday'),
    (7, 'Sunday'),
  ];

  bool get isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _subjectController.text = widget.schedule!.subjectName;
      _roomController.text = widget.schedule!.room;
      _instructorController.text = widget.schedule!.instructor;
      _dayOfWeek = widget.schedule!.dayOfWeek;
      _startTime = widget.schedule!.startTime;
      _endTime = widget.schedule!.endTime;
      _colorHex = widget.schedule!.colorHex;
    } else {
      _dayOfWeek = DateTime.now().weekday;
      if (_dayOfWeek > 7) _dayOfWeek = 1;
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 30);
      _colorHex = _colors[0];
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Check if end time is after start time
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final provider = context.read<ScheduleProvider>();

    if (isEditing) {
      final updated = ClassSchedule(
        id: widget.schedule!.id,
        subjectName: _subjectController.text.trim(),
        room: _roomController.text.trim(),
        instructor: _instructorController.text.trim(),
        dayOfWeek: _dayOfWeek,
        startTime: _startTime,
        endTime: _endTime,
        colorHex: _colorHex,
      );
      provider.updateSchedule(updated);
      _scheduleClassNotification(updated);
    } else {
      final schedule = ClassSchedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subjectName: _subjectController.text.trim(),
        room: _roomController.text.trim(),
        instructor: _instructorController.text.trim(),
        dayOfWeek: _dayOfWeek,
        startTime: _startTime,
        endTime: _endTime,
        colorHex: _colorHex,
      );
      provider.addSchedule(schedule);
      _scheduleClassNotification(schedule);
    }

    Navigator.pop(context);
  }

  void _scheduleClassNotification(ClassSchedule schedule) {
    // Alert 15 minutes before class
    int notifyHour = schedule.startTime.hour;
    int notifyMinute = schedule.startTime.minute - 15;
    
    if (notifyMinute < 0) {
      notifyMinute += 60;
      notifyHour -= 1;
      if (notifyHour < 0) notifyHour += 24;
    }

    NotificationService().scheduleWeeklyNotification(
      id: schedule.id.hashCode,
      title: 'Upcoming Class',
      body: '${schedule.subjectName} starts in 15 minutes${schedule.room.isNotEmpty ? ' in ${schedule.room}' : ''}',
      dayOfWeek: schedule.dayOfWeek,
      hour: notifyHour,
      minute: notifyMinute,
    );
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto update end time to be 1.5 hours later if it was before
          final startMins = _startTime.hour * 60 + _startTime.minute;
          final endMins = _endTime.hour * 60 + _endTime.minute;
          if (endMins <= startMins) {
            int newEndHour = _startTime.hour + 1;
            int newEndMin = _startTime.minute + 30;
            if (newEndMin >= 60) {
              newEndMin -= 60;
              newEndHour += 1;
            }
            if (newEndHour < 24) {
              _endTime = TimeOfDay(hour: newEndHour, minute: newEndMin);
            }
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Class' : 'Add Class',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Subject Name
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name *',
                    hintText: 'e.g. Computer Science 101',
                    prefixIcon: Icon(Icons.class_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Room and Instructor
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(
                          labelText: 'Room (optional)',
                          hintText: 'e.g. Room 302',
                          prefixIcon: Icon(Icons.room_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Instructor (optional)',
                    hintText: 'e.g. Dr. Smith',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                
                // Day of Week
                const Text(
                  'Day of the Week',
                  style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _dayOfWeek,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  items: _days.map((d) {
                    return DropdownMenuItem<int>(
                      value: d.$1,
                      child: Text(d.$2),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _dayOfWeek = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Times
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Time',
                            prefixIcon: Icon(Icons.access_time_rounded),
                          ),
                          child: Text(_formatTime(_startTime)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Time',
                            prefixIcon: Icon(Icons.access_time_rounded),
                          ),
                          child: Text(_formatTime(_endTime)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Color Picker
                const Text(
                  'Color Theme',
                  style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colors.map((color) {
                    final isSelected = _colorHex == color;
                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(color).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                
                // Save Button
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Class' : 'Add Class',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
