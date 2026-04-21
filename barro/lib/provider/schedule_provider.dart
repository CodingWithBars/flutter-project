import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/storage_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<ClassSchedule> _schedules = [];
  bool _isLoaded = false;

  List<ClassSchedule> get schedules => List.unmodifiable(_schedules);
  bool get isLoaded => _isLoaded;

  Future<void> loadSchedules() async {
    if (_isLoaded) return;
    try {
      final data = await StorageService.loadSchedules();
      if (data.isEmpty) {
        _schedules = _getDummySchedules();
      } else {
        _schedules = data.map((e) => ClassSchedule.fromJson(e)).toList();
      }
    } catch (e) {
      _schedules = _getDummySchedules();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveSchedules() async {
    final data = _schedules.map((s) => s.toJson()).toList();
    await StorageService.saveSchedules(data);
  }

  void addSchedule(ClassSchedule schedule) {
    _schedules.add(schedule);
    _saveSchedules();
    notifyListeners();
  }

  void updateSchedule(ClassSchedule schedule) {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      _saveSchedules();
      notifyListeners();
    }
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    _saveSchedules();
    notifyListeners();
  }

  List<ClassSchedule> getSchedulesForDay(int dayOfWeek) {
    final items = _schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();
    items.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour) != 0
        ? a.startTime.hour.compareTo(b.startTime.hour)
        : a.startTime.minute.compareTo(b.startTime.minute));
    return items;
  }

  ClassSchedule? getUpNextClass() {
    if (_schedules.isEmpty) return null;
    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday
    
    // Check today's remaining classes
    final todayClasses = getSchedulesForDay(currentDay);
    for (var c in todayClasses) {
      if (c.startTime.hour > now.hour ||
          (c.startTime.hour == now.hour && c.startTime.minute > now.minute)) {
        return c;
      }
    }
    
    // If no more classes today, find the next available day
    for (int i = 1; i <= 7; i++) {
      int nextDay = currentDay + i;
      if (nextDay > 7) nextDay -= 7;
      
      final nextDayClasses = getSchedulesForDay(nextDay);
      if (nextDayClasses.isNotEmpty) {
        return nextDayClasses.first;
      }
    }
    
    return null;
  }

  List<ClassSchedule> _getDummySchedules() {
    return [
      ClassSchedule(
        id: '1',
        subjectName: 'Computer Science 101',
        room: 'Room 302',
        instructor: 'Dr. Smith',
        dayOfWeek: 1, // Monday
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        colorHex: 0xFF7C3AED,
      ),
      ClassSchedule(
        id: '2',
        subjectName: 'Mathematics 201',
        room: 'Room 105',
        instructor: 'Prof. Johnson',
        dayOfWeek: 1, // Monday
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 30),
        colorHex: 0xFF06B6D4,
      ),
      ClassSchedule(
        id: '3',
        subjectName: 'Physics 101',
        room: 'Lab 2',
        instructor: 'Dr. Brown',
        dayOfWeek: 3, // Wednesday
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        colorHex: 0xFF10B981,
      ),
    ];
  }
}
