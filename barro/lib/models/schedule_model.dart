import 'package:flutter/material.dart';

class ClassSchedule {
  final String id;
  String subjectName;
  String room;
  String instructor;
  int dayOfWeek; // 1 = Monday, 7 = Sunday
  TimeOfDay startTime;
  TimeOfDay endTime;
  int colorHex;

  ClassSchedule({
    required this.id,
    required this.subjectName,
    this.room = '',
    this.instructor = '',
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.colorHex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectName': subjectName,
        'room': room,
        'instructor': instructor,
        'dayOfWeek': dayOfWeek,
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'endTimeHour': endTime.hour,
        'endTimeMinute': endTime.minute,
        'colorHex': colorHex,
      };

  factory ClassSchedule.fromJson(Map<String, dynamic> json) => ClassSchedule(
        id: json['id'] as String,
        subjectName: json['subjectName'] as String,
        room: json['room'] as String? ?? '',
        instructor: json['instructor'] as String? ?? '',
        dayOfWeek: json['dayOfWeek'] as int,
        startTime: TimeOfDay(
          hour: json['startTimeHour'] as int,
          minute: json['startTimeMinute'] as int,
        ),
        endTime: TimeOfDay(
          hour: json['endTimeHour'] as int,
          minute: json['endTimeMinute'] as int,
        ),
        colorHex: json['colorHex'] as int? ?? 0xFF7C3AED,
      );
}
